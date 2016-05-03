rm(list = ls())
source('main.R')

########################
#
# Demo of the ESNN
#
########################
doTheTest <- function(datasetName, esnn){
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

    enc <- SpikeEncoding$new(nbFields = 20, beta = 1.5, iMin = 0, iMax= 8)

    esnnIris <- ESNN$new(encoder = enc, m=0.9, c=0.7, s=0.6)
    esnnIris$train(irisTrainSet)
    irisTestResults <- esnnIris$test(irisTestSet)
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
    return(BCTestResults)
  }
}

cat('\nTesting on Iris dataset\n')
i <- suppressWarnings(doTheTest('i'))
cat(paste('Iris dataset done. Use: \n\t`i$stats` for overall stats \n\t`i$precision`, `i$accuracy` or `i$recall` \nto view the results.\n'))

cat('\nTesting on Spiral dataset\n')
s <- suppressWarnings(doTheTest('s'))
cat(paste('Spiral dataset done. Use: \n\t`s$stats` for overall stats \n\t`s$precision`, `s$accuracy` or `s$recall` \nto view the results.\n'))
