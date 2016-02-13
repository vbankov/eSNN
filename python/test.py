'''
Created on 13/02/2012

@author: stefan
'''
import unittest
import numpy

from esnn import PopulationEncoding, ESNN

class TestESNN(unittest.TestCase):


    def setUp(self):
        pass
         


    def tearDown(self):
        pass


    def test_convert(self):
        encoder = PopulationEncoding(nb_fields=5, beta=2., i_min=-1.5, i_max=1.5)
        
        # check if the centers of the Gaussians have been computed properly
        self.assertTrue((encoder.mu==[-2., -1.,  0.,  1.,  2.]).all())
        
        # check the Gaussian sigma
        self.assertTrue(encoder.sigma==0.5)
        
        # compute the maximum a the receptive field
        s, m, x = 0.5, 0., 0.
        gauss = lambda sigma,mu,x: 1./(sigma * numpy.sqrt(2.*numpy.pi)) * numpy.exp(- (x-mu)**2 / (2.* sigma**2))
        self.assertTrue(encoder.rcf_max == gauss(s,m,x))

        # assert that the results of conversion are as expected        
        delays = encoder.convert([0.75])
        expected_delays = numpy.array([0.99999973, 0.99781251, 0.67534753, 0.1175031, 0.95606307])
        self.assertTrue((numpy.abs(delays-expected_delays) < 0.001).all())

        # run the encoding several times and make sure the results are identical
        for runs in xrange(10):
            delays = encoder.convert([0.75])
            self.assertTrue((numpy.abs(delays-expected_delays) < 0.001).all())
            
        # test the conversion of a vector
        delays = encoder.convert([0.75, 0.75, 0.75])
        self.assertTrue(len(delays) == 3*5)
        d = numpy.array([expected_delays]*3).flatten()
        self.assertTrue((numpy.abs(delays-d) < 0.001).all())

    def testESNN(self):
        encoder = PopulationEncoding(nb_fields=10, beta=1.5, i_min=0, i_max=1.5)
        esnn = ESNN(encoder=encoder, c=0.7,s=0.0)
        
        # generate some simple data
        data = numpy.array([[0,0],
                            [1,1]])
        
        # train the classifier
        esnn.train(data)
        
        # check on the results
        labels, accuracy = esnn.test(data)
        self.assertTrue(labels==[0,1])
        self.assertTrue(accuracy==1.)
        self.assertTrue(esnn.repos.keys()==[0,1])


if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()