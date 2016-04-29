###
#
# @author: Vasilis Bankov
# Notes:
#   R6 OO                   https://cran.r-project.org/web/packages/R6/vignettes/Introduction.html
#   OO                      http://adv-r.had.co.nz/OO-essentials.html
#   Cheatsheet              http://mathesaurus.sourceforge.net/r-numpy.html
#   Profiling & Optimizing  http://adv-r.had.co.nz/Profiling.html
#
###

###
#
# Load the libraries we depend on
#
###
library(R6)
library(caret)

###
#
# Define the classes
#
###

source('SpikeEncoding.R')

source('TrainedNeuron.R')

source('Repo.R')

source('ESNN.R')