Repo <- R6Class('Repo',
  public = list(
    label = NA,
    neurons = c(),
    initialize = function(label){
      self$label <- label
    },
    append = function(neuron){
      self$neurons <- c(self$neurons, neuron)
    }
  )
)