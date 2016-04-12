##
#   Class:  Population Encoding
#
# Description:
#   Implementation of the population encoding using Gaussian receptive fields
#   as described in BOTHE et al.
##
SpikeEncoding <- R6Class("SpikeEncoding",

  # Public Stuff
  public = list(

    # Encoder Attributes
    nbFields = NA,
    beta = NA,
    iMin = NA,
    iMax = NA,

    # Initialization
    initialize = function(nbFields, beta, iMin, iMax) {
      stuffIsCool <- private$checkInitializationConsistency(nbFields, beta, iMin, iMax)
      if(!stuffIsCool){
        # Something's missing
        cat('---\tOops !!\t---\n-\tThere was an error initializing SpikeEncoding. An argument seems to be missing.')
      }else{
        # Set the encoder attributes
        self$nbFields <<- nbFields  # number of receptive fields
        self$beta <<- beta          # width of each receptive field
        self$iMin <<- iMin          # center of first receptive field
        self$iMax <<- iMax          # center of last receptive field

        # compute mu and sigma for the Gaussian receptive fields
        private$fields = seq(1,nbFields)
        private$mu = self$iMin + (2*private$fields-3)/2 * (self$iMax-self$iMin)/(self$nbFields-2)
        private$sigma = 1/self$beta * (self$iMax-self$iMin)/(self$nbFields-2)
        private$rcfMax = private$rcf(private$mu[1])[1]

      }
    },

    # Public Functions
    convert = function(vect){
      # loop through all values of the vector
      # and compute the response of the receptive fields
      l_response_vec <- c()

      for(v in vect){
        response_vec <- private$rcf(v) / private$rcfMax
        l_response_vec <- c(l_response_vec, response_vec)
      }

      a_response_vec <- - l_response_vec +1

      return(a_response_vec)
    }
  ),

  # Private Stuff
  private = list(

    # Private Variables
    fields = list(),
    mu = NA,
    sigma = NA,
    rcfMax = NA,

    # Private Functions
    checkInitializationConsistency = function(nbFields, beta, iMin, iMax){ # check initialization consistency
      return( !missing(nbFields) && !missing(beta) && !missing(iMin) && !missing(iMax)  ) # no argument should be missing
    },
    rcf = function(x){  # create a function for all receptive fields
      return ( 1 / (private$sigma * sqrt(2*pi)) * exp(- (x-private$mu)**2 / (2.* private$sigma**2)) )
    }
  )
)