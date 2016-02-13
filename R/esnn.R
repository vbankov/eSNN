###
#
# @author: Vasilis Bankov
# Notes:
#   0           https://cran.r-project.org/web/packages/R6/vignettes/Introduction.html
#   1           http://adv-r.had.co.nz/OO-essentials.html
#   Cheatsheet  http://mathesaurus.sourceforge.net/r-numpy.html
###

########################
#
# Dev Stuff Part I
# WARNING: Delete before doing anything serious !
#
########################
setwd("C:/Users/vasil/Dropbox/Thesis/xD/theNewBeginning/R")

########################
#
# Load the libraries
#
########################
library(R6)

########################
#
# Define the classes
#
########################

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
        private$rcfMac = private$rcf(private$mu[1])[1]

      }
    },

    # Public Functions
    convert = function(vec){
      # loop through all values of the vector
      # and compute the response of the receptive fields
      l_response_vec <- []

      ## TODO: Continue from here
      ## TODO: Continue from here
      ## TODO: Continue from here
      ## TODO: Continue from here
      
      # for v in vec:
      #     response_vec = self.rcf(v) / self.rcf_max
      #     l_response_vec.extend(response_vec)
      
      # transform the response into delay times
      a_response_vec <- -seq(l_response_vec)
        
        return a_response_vec
    },

    example = function() {
      #if (private$length() == 0) return(NULL)  # dev note: this cancels stuff
    }

  ),

  # Private Stuff
  private = list(

    # Private Variables
    fields = list(),
    mu = NA,
    sigma = NA,

    # example = list(),

    # Private Functions
    # length = function() base::length(private$queue)
    checkInitializationConsistency = function(nbFields, beta, iMin, iMax){ # check initialization consistency
      return( !missing(nbFields) && !missing(beta) && !missing(iMin) && !missing(iMax)  ) # no argument should be missing
    },
    rcf = function(x){  # create a function for all receptive fields
      return ( 1 / (private$sigma * sqrt(2*pi)) * exp(- (x-private$mu)**2 / (2.* private$sigma**2)) )
    }

  )
)


########################
#
# Dev Stuff Part II
# WARNING: Delete before doing anything serious !
#
########################
encoder <- SpikeEncoding$new(20,1.5,-1,1)
