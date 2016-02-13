'''
Created on 14/02/2012
@author: stefan

Example on how to use the eSNN implementation. We will load the spiral 
data set, split the data into a training and a testing set and then 
train and test the eSNN classifier.

Check the documentation for more details.

'''

####################################################################
####################################################################

from pylab import *
import time
from esnn import ESNN, PopulationEncoding

####################################################################
####################################################################

if __name__ == "__main__":

    # we will record the elapsed time
    t_start = time.time()
    
    ################################################################
    # load the spiral data set
    ################################################################

    data = loadtxt('data/spiral.data')
    data = data[:,array([0,1,2,3,4,5,20])] # select only the first six features along with the class label
    
    # shuffle the data
    seed(12345)     # specify a random seed for reproducibility of results!
    shuffle(data)   # now create a random order of the data

    
    ################################################################
    # training and testing
    ################################################################
    
    # We use population encoding with 20 Gaussian receptive fields per variable,
    # a Gaussian width parameter beta=1.5. The data is normalized to [-1,1], so we 
    # indicate the coverage of the Gaussians using i_min and i_max 
    encoder = PopulationEncoding(nb_fields=20, beta=1.5, i_min=-1, i_max=1)
    
    # Create the eSNN using population encoding, a modulation factor m=0.9,
    # the simularity threshold s=0.0 and the firing threshold ratio of c=0.7. 
    esnn = ESNN(encoder=encoder, m=0.9, c=0.7, s=0.6)
    
    # train the classifier on the first 300 samples
    esnn.train(data[0:300])
    
    # test the classifier on the remaining 100 samples
    labels, accuracy = esnn.test(data[300:])
    
    # stop the time recording
    t_end = time.time()


    ################################################################
    # print the computed results
    ################################################################
    
    print 'Class\tPred.\tCorrect'
    print '--------------------------'
    for prediction, actual in zip(labels, data[300:,-1]):
        print '  %d\t  %d\t  %s' % (actual, prediction, ['F','T'][prediction==actual])
    
    print 'Classification Accuracy: %0.1f%%' % (accuracy*100)
    
    print 'No. of evolved neurons:'
    for k in esnn.repos.keys():
        print '    Class %d:\t%d neurons' % (k, len(esnn.repos[k]))
    
    print 'Elapsed time: %0.2f sec' % (t_end - t_start)

    
