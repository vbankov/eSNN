'''
Created on 13/02/2012

@author: stefan
'''

import numpy
import pylab

class SpikeEncoding(object):
    '''
    Abstract class that encapsulates the transformation of real-valued input data
    into trains of spikes
    '''
    
    def __init__(self, **kwargs):
        '''
        '''
        # we store all parameters as class members
        for key, value in kwargs.items():
            setattr(self, key, value)
    
    def convert(self, vec):
        '''
        Converts a real-valued vector into spike times of a group of neurons.
        '''
    
class PopulationEncoding(SpikeEncoding):
    '''
    Implementation of the population encoding using Gaussian receptive fields as
    described in BOTHE et al.
    '''
    
    REQUIRED_PARAMS = ['nb_fields', # number of receptive fields 
                       'beta',      # width of each receptive field 
                       'i_min',     # center of first receptive field   
                       'i_max']     # center of last receptive field
    
    def __init__(self, **kwargs):
        SpikeEncoding.__init__(self, **kwargs)
        
        # check if all parameters have been set by the constructor
        for p in self.REQUIRED_PARAMS:
            if getattr(self, p)==None:
                print "Attribute %s must be set for the PopulationEncoding!" % (p)

        # compute mu and sigma for the Gaussian receptive fields
        fields = numpy.arange(0, self.nb_fields)+1
        self.mu = self.i_min + (2.*fields-3.)/2. * (self.i_max-self.i_min)/(self.nb_fields-2.)
        self.sigma = 1./self.beta * (self.i_max-self.i_min)/(self.nb_fields-2.)

        # create a function for all receptive fields        
        self.rcf = lambda x:  1./(self.sigma * numpy.sqrt(2.*numpy.pi)) * numpy.exp(- (x-self.mu)**2 / (2.* self.sigma**2));
        
        # compute the maximum output of a receptive field for normalization purposes
        self.rcf_max = self.rcf(self.mu[0])[0]
        
    
    def convert(self, vec):
        
        # loop through all values of the vector
        # and compute the response of the receptive fields
        l_response_vec = []
        for v in vec:
            response_vec = self.rcf(v) / self.rcf_max
            l_response_vec.extend(response_vec)
        
        # transform the response into delay times
        a_response_vec = -numpy.array(l_response_vec) + 1.
        
        return a_response_vec
        
        

class ESNN(object):
    '''
    Implementation of the Evolving Spiking Neural Network (eSNN) classification
    algorithm as introduced in REF.
    '''
    
    class TrainedNeuron():
        '''
        Encapsulates a single trained neuron
        '''
        def __init__(self, w, theta, nb_merges, label):
            self.w = w
            self.theta = theta
            self.nb_merges = nb_merges
            
            self.psp = 0.
            self.label = label
            

    def __init__(self, encoder=None, m=0.9, s=0.1, c=0.7):
        '''
        '''
        
        self.encoder = encoder
        self.m = m  # modulation factor
        self.s = s  # similarity threshold
        self.c = c  # ratio of firing threshold
        
        self.repos = {}

        # latest firing time of an input neuron
        self.max_response_time = 1. - 0.1
        
    
    def train(self, data):
        '''
        Trains the eSNN classifier. Note that the training accumulates! Call 
        reset() to start a new training session with an empty neuron repository.
        
        @param data: Training data. Each row represents one sample, each column
            one feature. The last column represents the class label of the sample.
        '''
        
        # last column is the class label
        label = data[:,-1]
        samples = data[:,:-1]
        
        # check if we have individual repositories for all labels already
        for l in set(label):
            if l not in self.repos.keys():
                # no, we don't know this label, yet, so we add it
                self.repos.update({l:[]})
        
        for i,sample in enumerate(samples):
            
            # load label
            l = label[i]
            
            # convert sample into spike times
            spikes = self.encoder.convert(sample)
            
            # compute the weights, max PSP and the firing threshold
            w, theta = self._train_sample(spikes)
            
            # find similar neurons
            neuron = self._find_similar(w, l)
        
            # if we already have trained a similar neuron earlier,
            # then merge with the one we have just trained
            if neuron:
                self._merge(neuron, self.TrainedNeuron(w, theta, 0, None))
            # otherwise, we just add the newly trained neuron into the repository    
            else:
                self.repos[l].append(self.TrainedNeuron(w, theta, 1, l))

    def _merge(self, neuron1, neuron2):
        '''
        Merges the weight vectors and the firing threshold of the two neurons
        and writes the result back to neuron1.
        '''
        neuron1.w = (neuron2.w + neuron1.nb_merges*neuron1.w) / (1.+neuron1.nb_merges)
        neuron1.theta = (neuron2.theta + neuron1.nb_merges*neuron1.theta) / (1.+neuron1.nb_merges)
        neuron1.nb_merges += 1

    def _find_similar(self, weights, label):
        '''
        Searches for a similar neuron in the repository of trained neurons
        that belong to the specified class. 
        '''
        
        # first we check, if there is any neuron in the repository belonging
        # to the given class
        if len(self.repos[label])==0:
            # if there is no neuron in the repository, we can stop here
            return None
        
        # find the neuron with the smallest distance to the given weight vector 
        l_dist = []
        for neuron in self.repos[label]:
            l_dist.append(numpy.linalg.norm(neuron.w - weights))
        min_index = numpy.argmin(l_dist)
        min_dist = l_dist[min_index]
        
        if min_dist<self.s:
            return self.repos[label][min_index]
        else:
            return None
        
    
    def _train_sample(self, sample):
        '''
        Computes the weights of a training neuron based on the given input
        sample.
        
        Returns a tuple (weights, theta) representing the trained weight
        vector along with the firing threshold theta of the neuron.
        '''
        index = numpy.argsort(sample)
        weights = numpy.zeros(len(sample))
        weights[index] = self.m**numpy.arange(len(sample))

        # correct the weights for too late spikes
        index = pylab.find(sample > self.max_response_time)
        weights[index] = 0.
        
        u_max = numpy.sum(weights**2)
        theta = self.c * u_max
        
        return weights, theta
    
    def reset(self):
        '''
        Resets the repository of trained neurons.
        '''
        # remove all neurons from the repository and the neuron list
        self.all_neurons = []
        for k in self.repos.keys():
            del self.repos[k]
        del self.repos
        
    
    def test(self, data):
        '''
        Tests the eSNN classifier.
        
        @param data: Testing data. Each row represents one sample, each column
            one feature. The last column represents the class label of the sample.
        '''
        
        # last column is the class label
        label = data[:,-1]
        samples = data[:,:-1]
        
        # check if we have individual repositories for all labels already
        for l in set(label):
            if l not in self.repos.keys():
                # no, we don't know this label, yet, so we add it
                self.repos.update({l:[]})

        # update the list of all neurons
        self.all_neurons = []
        for k in self.repos.keys():
            self.all_neurons.extend(self.repos[k])

        # create a matrix of all weight vectors, all firing thresholds and all PSPs
        # NOTE: this step intends to accelerate the propagation method _propagate_fast()
        self.weight_matrix = []
        self.all_theta = [] 
        for n in self.all_neurons:
            self.weight_matrix.append(n.w)
            self.all_theta.append(n.theta)
        self.weight_matrix = numpy.array(self.weight_matrix)
        self.all_theta = numpy.array(self.all_theta)
        self.all_psp = numpy.zeros(len(self.all_neurons))
        
        # prepare results
        nb_correct = 0
        classified_labels = []
        
        # loop over all samples of the data set        
        for i,sample in enumerate(samples):
            
            # load label
            l = label[i]
            
            # convert sample into spike times
            spikes = self.encoder.convert(sample)

            # find neuron that spikes first
            result = self._propagate_fast(spikes)
            if result:
                # the sample was classified into some known class
                # extract results and store
                neuron, spike_time, class_label = result
                
                # store classification result
                classified_labels.append(class_label)
                    
                # check the classification result
                if class_label == l:
                    nb_correct += 1
            else:
                # the sample was not classified (none of the neurons emitted a spike)
                # store classification result
                classified_labels.append(-1)
            
        # return the list of classifications and the classification accuracy
        return classified_labels, float(nb_correct)/float(len(data))
    
    def _propagate_fast(self, sample):
        '''
        Propagates the given input through the network and determines which
        neuron spikes first.
        
        Returns a tuple containing the first-spiking neuron, its spike time 
        and the corresponding class label. 
        '''

        # reset all PSPs        
        self.all_psp[:] = 0. 
                
        # event driven processing of the input sample
        # we loop over all sorted firing times of the input
        sorted = numpy.argsort(sample)
        for order, index in enumerate(sorted):
            #update the PSP of all neurons in the repository
            self.all_psp += self.weight_matrix[:,index] * self.m**order 
            
            # check threshold condition
            active_neurons = pylab.find(self.all_psp > self.all_theta)
            if len(active_neurons) > 0:
                # stop the simulation if any neuron has fired
                return self.all_neurons[active_neurons[0]], sample[index], self.all_neurons[active_neurons[0]].label
        
        # no neuron has fired
        return None

    
    def create(self, repos):
        '''
        Creates a trained repository of neurons based on the specified repository.
        '''
        self.reset()          # clean up
        self.repos = repos    # store the new repository


    def _propagate(self, sample):
        '''
        @deprecated: Use the much faster _propagate_fast() method instead
        
        Propagates the given input through the network and determines which
        neuron spikes first.
        
        Returns a tuple containing the first-spiking neuron, its spike time 
        and the corresponding class label. 
        '''
        
        # reset the psp of all neurons
        for n in self.all_neurons:
            n.psp = 0.
            
        # event driven processing of the input sample
        # we loop over all sorted firing times of the input
        sorted = numpy.argsort(sample)
        for order, index in enumerate(sorted):
            #update the state of all neurons in the repository
            for n in self.all_neurons:
                # accumulate the PSP
                n.psp += n.w[index]*self.m**order
                
                # check threshold condition
                if n.psp > n.theta:
                    # stop the simulation once a neuron has fired
                    return n, sample[index], n.label
        return None
