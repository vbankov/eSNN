##
#   Class:  Trained Neuron
#
# Description:
#   Encapsulates a single trained neuron
##
TrainedNeuron <-R6Class("TrainedNeuron",
  public = list(
    w = NA, 
    theta = NA, 
    nbMerges = NA, 
    label = NA,
    psp = NA,
    initialize = function(w, theta, nbMerges, label){
      stuffIsCool <- private$checkInitializationConsistency(w, theta, nbMerges, label)
      if(!stuffIsCool){
        # Something's missing
        cat('---\tOops !!\t---\n-\tThere was an error initializing TrainedNeuron. An argument seems to be missing.')
        }else{
          self$w <<- w
          self$theta <<- theta
          self$nbMerges <<- nbMerges
          self$label <<- label
          self$psp <<- 0
        }
    }
  ),
  private = list(
    checkInitializationConsistency = function(w, theta, nbMerges, label){ # check initialization consistency
      return( !missing(w) && !missing(theta) && !missing(nbMerges) && !missing(label)  ) # no argument should be missing
    }
  )
)