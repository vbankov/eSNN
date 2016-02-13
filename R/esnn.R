###
#
# @author: Vasilis Bankov
# Notes:
#   0 https://cran.r-project.org/web/packages/R6/vignettes/Introduction.html
#   1 http://adv-r.had.co.nz/OO-essentials.html
#
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
      a <- private$checkInitializationConsistency(nbFields, beta, iMin, iMax)
      if(a==FALSE){
        cat('---\tOops !!\t---\n-\tThere was an error initializing SpikeEncoding. An argument seems to be missing.')
      };
      # for (item in list(...)) {
      #   self$add(item)
      # }
    },

    # Methods
    methods = list(
      # set = function(value) x <<- value  # setter: variableName$set(10)
      # get = function() x,         # getter: variableName$get()
    ),


    # Public Functions
    example = function() {
      #if (private$length() == 0) return(NULL)  # dev note: this cancels stuff
    }

  ),

  # Private Stuff
  private = list(

    # Private Variables
    # example = list(),

    # Private Functions
    # length = function() base::length(private$queue)
    checkInitializationConsistency = function(nbFields, beta, iMin, iMax){
      return( !missing(nbFields) && !missing(beta) && !missing(iMin) && !missing(iMax)  ) # no argument should be missing
    }

  )
)


########################
#
# Dev Stuff Part II
# WARNING: Delete before doing anything serious !
#
########################
encoder <- SpikeEncoding$new(1,2)
