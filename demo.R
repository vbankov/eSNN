rm(list = ls())
source('main.R')

########################
#
# Demo of the ESNN
#
########################
doTheTest <- function(datasetName){
  availableDataSets <- c('s', 'i', 'w' ,'bc')   # spiral / iris / wine / breast cancer

  if(length(which(availableDataSets==datasetName))==0){
    cat(paste('\nDataset unknown. Availale are ',availableDataSets))
    return()
  }

  encoder <- SpikeEncoding$new(nbFields = 20, beta = 1.5, iMin = -1, iMax= 1)

  if(datasetName=='i'){ # iris
    irisData <- read.csv(file="data/iris.data", header=FALSE, sep=" ")
    baseIrisData <- as.data.frame(c(irisData[,1:4], irisData[5]))
    shuffledIrisData <- baseIrisData[sample(nrow(baseIrisData)),]
    irisTrainSet <- shuffledIrisData[1:100,]
    irisTestSet <- shuffledIrisData[101:150,]

    esnnIris <- ESNN$new(encoder = encoder, m=0.9, c=0.7, s=0.6)
    esnnIris$train(irisTrainSet)
    irisTestResults <- esnnIris$test(irisTestSet)

    cat(paste('\n========== Iris Results (100 train/ 50 test) ==========\n'))
    cat(paste('repo 1: ',length(esnnIris$repos[[1]]$neurons), ' neurons\n'))
    cat(paste('repo 2: ',length(esnnIris$repos[[2]]$neurons), ' neurons\n'))
    cat(paste('repo 3: ',length(esnnIris$repos[[3]]$neurons), ' neurons\n'))

    cat(paste('acc: ',irisTestResults$accuracy*100 ))
    return(irisTestResults)
  }else if(datasetName=='s'){ # spiral
    data <- read.csv(file="data/spiral.data", header=FALSE, sep=" ")
    baseData <- as.data.frame(c(data[,1:6], data[21]))
    shuffledData <- baseData[sample(nrow(baseData)),]
    trainSet <- shuffledData[1:300,]
    testSet <- shuffledData[301:400,]
    esnn <- ESNN$new(encoder = encoder, m=0.9, c=0.7, s=0.6)
    esnn$train(trainSet)
    testResults <- esnn$test(testSet)

    cat(paste('\n========== Spiral Results (300 train/ 100 test) ==========\n'))
    cat(paste('repo 1: ',length(esnn$repos[[1]]$neurons), ' neurons\n'))
    cat(paste('repo 2: ',length(esnn$repos[[2]]$neurons), ' neurons\n'))
    cat(paste('acc: ', testResults$accuracy*100 ))
    return(testResults)
  }else if(datasetName=='w'){ # wine
    data <- read.csv(file="data/wine.data", header=FALSE, sep=",")
    baseWineData <- as.data.frame(c(data[,2:14], data[1]))
    shuffledWineData <- baseWineData[sample(nrow(baseWineData)),]
    wineTrainSet <- shuffledWineData[1:118,]
    wineTestSet <- shuffledWineData[119:178,]
    esnnWine <- ESNN$new(encoder = encoder, m=0.9, c=0.7, s=0.6)
    esnnWine$train(wineTrainSet)
    wineTestResults <- esnnWine$test(wineTestSet)

    cat(paste('\n========== Wine Results (118 train/ 59 test) ==========\n'))
    cat(paste('repo 1: ',length(esnnWine$repos[[1]]$neurons), ' neurons\n'))
    cat(paste('repo 2: ',length(esnnWine$repos[[2]]$neurons), ' neurons\n'))
    cat(paste('repo 3: ',length(esnnWine$repos[[3]]$neurons), ' neurons\n'))
    cat(paste('acc: ', wineTestResults$accuracy*100 ))
    return(wineTestResults)
  }else if(datasetName=='bc'){ # breast cancer
    data <- read.csv(file="data/wdbc.data", header=FALSE, sep=",")
    baseBCData <- as.data.frame(c(data[,3:32], data[2]))
    shuffledBCData <- baseBCData[sample(nrow(baseBCData)),]
    BCTrainSet <- shuffledBCData[1:379,]
    wintTestSet <- shuffledBCData[380:569,]
    esnnBC <- ESNN$new(encoder = encoder, m=0.9, c=0.7, s=0.6)
    esnnBC$train(BCTrainSet)
    BCTestResults <- esnnBC$test(wintTestSet)

    cat(paste('\n========== BC Results (379 train/ 190 test) ==========\n'))
    cat(paste('repo 1: ',length(esnnBC$repos[[1]]$neurons), ' neurons\n'))
    cat(paste('repo 2: ',length(esnnBC$repos[[2]]$neurons), ' neurons\n'))

    cat(paste('acc: ', BCTestResults$accuracy*100 ))
    return(BCTestResults)
  }

}

repCount <- 10

cat(paste('\n\tExperiment 1/4 : Iris dataset\n'))
irisAccuracies <- c()
for(i in 1:repCount){
  res <- doTheTest('i')
  cat(paste('\n\tRep ',i,'/',repCount,'\n'))
  irisAccuracies <- c(irisAccuracies, res$accuracy)
}
cat(paste('\n========== Iris experiment done ==========\n'))
cat(paste('Iris Mean accuracy: ',mean(irisAccuracies),'\n\n'))

cat(paste('\n\tExperiment 2/4 : Spiral dataset\n'))
spiralAccuracies <- c()
for(i in 1:repCount){
  res <- doTheTest('s')
  cat(paste('\n\tRep ',i,'/',repCount,'\n'))
  spiralAccuracies <- c(spiralAccuracies, res$accuracy)
}
cat(paste('\n========== Spiral experiment done ==========\n'))
cat(paste('Spiral Mean accuracy: ',mean(spiralAccuracies),'\n\n'))

cat(paste('\n\tExperiment 3/4 : Wine dataset\n'))
wineAccuracies <- c()
for(i in 1:repCount){
  res <- doTheTest('w')
  cat(paste('\n\tRep ',i,'/',repCount,'\n'))
  wineAccuracies <- c(wineAccuracies, res$accuracy)
}
cat(paste('\n========== Wine experiment done ==========\n'))
cat(paste('Wine Mean accuracy: ',mean(wineAccuracies),'\n\n'))

cat(paste('\n\tExperiment 4/4 : Breast cancer dataset\n'))
bcAccuracies <- c()
for(i in 1:repCount){
  res <- doTheTest('bc')
  cat(paste('\n\tRep ',i,'/',repCount,'\n'))
  bcAccuracies <- c(bcAccuracies, res$accuracy)
}
cat(paste('\n========== BC experiment done ==========\n'))
cat(paste('Breast cancer Mean accuracy: ',mean(bcAccuracies),'\n\n'))