source('main.R')

########################
#
# Demo of the ESNN
#
########################

source('SpikeEncoding.R')

source('TrainedNeuron.R')

source('Repo.R')

data <- read.csv(file="data/spiral.data", header=FALSE, sep=" ")
irisData <- read.csv(file="data/iris.data", header=FALSE, sep=" ")

baseData <- as.data.frame(c(data[,1:6], data[21]))
baseIrisData <- as.data.frame(c(irisData[,1:4], irisData[5]))

shuffledData <- baseData[sample(nrow(baseData)),]
shuffledIrisData <- baseIrisData[sample(nrow(baseIrisData)),]

trainSet <- shuffledData[1:300,]
testSet <- shuffledData[301:400,]

irisTrainSet <- shuffledIrisData[1:100,]
irisTestSet <- shuffledIrisData[101:150,]

encoder <- SpikeEncoding$new(nbFields =20, beta = 1.5, iMin = -1, iMax= 1)

esnn <- ESNN$new(encoder = encoder, m=0.9, c=0.7, s=0.6)
esnnIris <- ESNN$new(encoder = encoder, m=0.9, c=0.7, s=0.6)

esnn$train(trainSet)
testResults <- esnn$test(testSet)
esnnIris$train(irisTrainSet)
irisTestResults <- esnnIris$test(irisTestSet)

cat(paste('\n========== Spiral Results ==========\n'))
cat(paste('repo 1: ',length(esnn$repos[[1]]$neurons), ' neurons\n'))
cat(paste('repo 2: ',length(esnn$repos[[2]]$neurons), ' neurons\n'))
cat(paste('acc: ', testResults$accuracy*100 ))

cat(paste('\n========== Iris Results ==========\n'))
cat(paste('repo 1: ',length(esnnIris$repos[[1]]$neurons), ' neurons\n'))
cat(paste('repo 2: ',length(esnnIris$repos[[2]]$neurons), ' neurons\n'))
cat(paste('repo 3: ',length(esnnIris$repos[[3]]$neurons), ' neurons\n'))

cat(paste('acc: ',irisTestResults$accuracy*100 ))
