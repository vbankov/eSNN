source('main.R')

########################
#
# Dev Stuff Part II
# WARNING: Delete before doing anything serious !
#
########################
data <- read.csv(file="data/spiral.data", header=FALSE, sep=" ")

trainSet <- data[1:300,]
testSet <- data[301:400,]

encoder <- SpikeEncoding$new(20,1.5,-1,1)
esnn <- ESNN$new(encoder = encoder, m=0.9, c=0.7, s=0.6)

esnn$train(trainSet)
