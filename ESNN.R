##
#   Class:  ESNN
#
# Description:
#   Implementation of the Evolving Spiking Neural Network (eSNN) classification
#   algorithm as introduced in REF.
#
# @author: Vasilis Bankov
##

ESNN <- R6Class("ESNN",
  public = list(
    encoder = NA,
    m = NA, # modulation factor
    s = NA, # similarity threshold
    c = NA, # ratio of firing threshold
    repos = list(),
    maxResponseTime = .9, # latest firing time of an input neuron

    # Initialization
    initialize = function(encoder, m, s, c){
      stuffIsCool <- private$checkInitializationConsistency(encoder, m, s, c)
      if(!stuffIsCool){
        # Something's missing
        cat('---\tOops !!\t---\n-\tThere was an error initializing SpikeEncoding. An argument seems to be missing.')
      }else{
        self$encoder <<- encoder
        self$m <<- m
        self$s <<- s
        self$c <<- c
      }
    },

    #   Trains the eSNN classifier. Note that the training accumulates! Call
    #   reset() to start a new training session with an empty neuron repository.

    #   @param data: Training data. Each row represents one sample, each column
    #       one feature. The last column represents the class label of the sample.
    train = function(data){
      labls <- as.data.frame(data[,length(data)])
      sampls <- as.data.frame(data[,1:length(data)-1])


      # we'll save the unique labels as string in our neuron repositories
      u <- unique(labls)[[1]]
      for(i in 1:length(u)){
        n <- Repo$new(as.character(u[i]))
        private$repoLabels <- c(private$repoLabels, as.character(u[i]))
        self$repos <- c(self$repos, n)
      }


      for(i in 1:length(sampls[,1])){
        sampl <- sampls[i,]

        # load label
        l <- labls[i,]

        # convert sample into spike times
        spikes <- self$encoder$convert(sampl)

        # compute the weights, max PSP and the firing threshold
        params <- private$trainSample(spikes)
        w <- params$w
        theta <- params$theta

        # find similar neurons
        similarNeuron <- private$findSimilar(w, l)

        if(!is.null(similarNeuron)){
          newNeuron <- TrainedNeuron$new(w=w, theta = theta, 0, NULL)
          mergedNeuron <- private$merge(similarNeuron$neuron, newNeuron)
          ll <- which(private$repoLabels==mergedNeuron$label)
          self$repos[[ll]]$neurons[[similarNeuron$index]] <- NULL
          self$repos[[ll]]$neurons[[similarNeuron$index]] <- mergedNeuron
        }else{
          ll <- which(private$repoLabels==l)
          self$repos[[ll]]$append(TrainedNeuron$new(w, theta, 1, l))
        }

      }

    },

    test = function(data){
      # Tests the eSNN classifier.

      # @param data: Testing data. Each row represents one sample, each column
      #     one feature. The last column represents the class label of the sample.

      # last column is the class label
      label <- as.data.frame(data[,ncol(data)])
      samples <- as.data.frame(data[,1:ncol(data)-1])

      # check if we have individual repositories for all labels already
      for (l in label) {
        if(length(which(private$repoLabels==l))<0){
          # no, we don't know this label, yet, so we add it
          private$repoLabels <- c(self$repoLabels, l)
        }
      }

      # update the list of all neurons
      for(k in private$repoLabels){
        kk <- which(private$repoLabels==k)
        private$all_neurons <- c(private$all_neurons, self$repos[[kk]]$neurons)
      }


      # create a matrix of all weight vectors, all firing thresholds and all PSPs
      # NOTE: this step intends to accelerate the propagation method propagate_fast()
      private$weight_matrix <- matrix(NA, nrow=length(private$all_neurons), ncol=length(private$all_neurons[[1]]$w))
      counter <- 1
      for(n in private$all_neurons){
        private$weight_matrix[counter,] <- n$w
        private$all_theta <- c(private$all_theta, n$theta)
        counter <- counter + 1
      }
      private$all_psp <- matrix(0,length(private$all_neurons))

      # prepare results
      nb_correct <- 0
      classified_labels <- c()
      resultsTable <- data.frame()

      # loop over all samples of the data set
      for(i in 1:length(samples[,1])){

        # load label
        testLabel <- label[i,]
        smpl <- samples[i,]

        # convert sample into spike times
        spikes <- self$encoder$convert(smpl)

        # find neuron that spikes first
        result <- private$propagate_fast(spikes)
        if(!is.null(result)){
          ## the sample was classified into some known class
          ## extract results and store

          neuron <- result$neuron
          spike_time <- result$spike_time
          class_label <- result$class_label

          ## store classification result
          classified_labels <- c(classified_labels, class_label)
          resultsTable <- rbind(resultsTable, data.frame(testLabel, class_label, class_label == testLabel) )
          ## check the classification result
          #cat(paste('\nLabel: ',class_label, ' correct: ',testLabel, ' ',(class_label == testLabel) ))
          if(class_label == testLabel){
            nb_correct <- nb_correct+1
          }

        }else{
          ## the sample was not classified (none of the neurons emitted a spike)
          ## store classification result
          classified_labels <- c(classified_labels, -1)
        }
      }

      ## return the list of classifications and the classification accuracy
      #return(list("classified_labels"=classified_labels, "accuracy"=nb_correct/length(data[,1])))
      names(resultsTable) <- c('label','classified','result')
      conf <- confusionMatrix(resultsTable$classified, resultsTable$label)

      confTable <- conf$table
      precision <- NaN
      if(dim(confTable)[[1]]<3){  # Only two classes are present, we'll calculate the precision
        b<- confTable[1,2]
        d<- confTable[2,2]
        cat('2 classes found, appending precision.\n')
        precision <- d / (b+d)
      }
      accuracy <- conf$overall[[1]]
      return(list(results=resultsTable, stats=conf, precision=precision, accuracy=accuracy))
    }

  ),

  private = list(
    weight_matrix = matrix(),
    all_neurons = c(),
    all_theta = c(),
    all_psp = NA,

    propagate_fast = function(sampl){
      # Propagates the given input through the network and determines which
      # neuron spikes first.

      # Returns a list containing the first-spiking neuron, its spike time
      # and the corresponding class label.

      # reset all PSPs
      private$all_psp <- matrix(0,length(private$all_neurons))

      # event driven processing of the input sample
      # we loop over all sorted firing times of the input
      sorted <- order(sampl)
      ordr <- 0
      for(index in sorted){
        #ordr <- sampl[index]
        #update the PSP of all neurons in the repository
        private$all_psp <- private$all_psp + private$weight_matrix[,index] * (self$m^ordr)

        # check threshold condition
        active_neurons <- which(private$all_psp > private$all_theta)

        if(length(active_neurons)>0){
          first_active_neuron_index <- active_neurons[1]
          first_active_neuron <- private$all_neurons[[first_active_neuron_index]]
          #cat(paste('fired neurons: ',length(active_neurons),' \tfirst_active_neuron_index:',first_active_neuron_index,'\n'))

          return(list("neuron"=first_active_neuron, "spike_time"=sampl[index], "class_label"= first_active_neuron$label ))
        }
        ordr <- ordr+1
      }
      #cat(paste('no neurons fired \n'))
      return(NULL)
    },

    merge = function(neuron1, neuron2){
      neuron1$w <- ( neuron2$w + neuron1$nbMerges*neuron1$w ) / ( 1 + neuron1$nbMerges )
      neuron1$theta <- ( neuron2$theta + neuron1$nbMerges * neuron1$theta ) / ( 1 + neuron1$nbMerges )
      neuron1$nbMerges <- neuron1$nbMerges+1
      return(neuron1)
    },

    repoLabels = c(),

    checkInitializationConsistency = function(encoder, m, s, c){ # check initialization consistency
      return( !missing(encoder) && !missing(m) && !missing(s) && !missing(c)  ) # no argument should be missing
    },

    trainSample = function(sample){
      # Computes the weights of a training neuron based on the given input sample.

      #   Returns a tuple (weights, theta) representing the trained weight
      #   vector along with the firing threshold theta of the neuron.
      index <- order(sample)
      weights <- matrix(0, length(sample)) # r equivalent to numpy.zeros(x)

      weights[index] <- self$m ^ (seq(length(sample))-1)

      # correct the weights for too late spikes
      weights[ sample[ sample > self$maxResponseTime ] ] <- 0

      u_max <- sum(weights^2)
      theta <- self$c * u_max

      return(list("weights"=weights, "theta"=theta))
    },

    findSimilar = function(weights, label) {
      # Searches for a similar neuron in the repository of trained neurons
      # that belong to the specified class.

      # first we check, if there is any neuron in the repository belonging
      # to the given class
      ll <- which(private$repoLabels==label)
      if(length(self$repos[[ll]]$neurons)==0){
        return(NULL)
      }

      l_dist <- c()
      o<-1
      for(neuron in self$repos[[ll]]$neurons){
        # linear norm
        nnn <- norm(as.matrix(c(neuron$w - weights)), type="F")
        l_dist <- c(l_dist, nnn)
      }
      min_index <- which.min(l_dist)
      min_dist <- min(l_dist)

      if(min_dist < self$s){
        return(c(label= label, index= min_index, neuron=self$repos[[ll]]$neurons[min_index]))
      }else{
        return(NULL)
      }

    }

  )
)