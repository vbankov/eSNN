0. Abstract


1 . Introduction

  Biological neurons use short and sudden increases in voltage to send information. These signals are
more commonly known as action potentials, spikes or pulses. Recent neurological research has
shown that neurons encode information in the timing of single spikes, and not only just in their average
firing frequency. Here is an introduction to spiking neural networks, some biological
background, and a presentation of two models of spiking neurons that employ pulse coding. Networks of
spiking neurons are more powerful than their non-spiking predecessors as they can encode temporal
information in their signals, but therefore do also need different and biologically more plausible rules
for synaptic plasticity.        [Spiking neural networks, an introduction - Jilles Vreeken (https://people.mmci.uni-saarland.de/~jilles/pubs/2002/spiking_neural_networks_an_introduction-vreeken.pdf)]

   To put it mildly: we do not understand the brain that well yet. 
In fact, we do not even completely understand the functioning of a single neuron. 
The chemical activity of the synapse already proves to be infinitely more complex than firstly assumed.
However, the rough concept of how neurons work is understood: neurons send out short pulses of electrical energy
as signals, if they have received enough of these themselves.

This basically simple mechanism has been moulded into a mathematical model for computer use. Artificial as these
computerised neurons are, we refer to them as networks of artificial neurons, or artificial neural networks. We will
sketch a short history of these now; the biological background of the real neuron will also be discussed in chapter 1. 

Generations of Artificial NNs:

  I.    McCulloch-Pitts threshold neurons [1] 
      
      a neuron sends a binary ‘high’ signal if the sum of its weighted incoming signals rises above a threshold value
      
      they have been successfully applied in powerful artificial neural networks like
        multi-layer perceptrons and Hopfield nets. For example, any function with Boolean output can be computed by a multilayer
        perceptron with a single hidden layer; these networks are called universal for digital computations
  
        The original work of McCulloch & Pitts in 1943 [110] proposed a neural network
        model based on simplified “binary” neurons, where a single neuron implements a
        simple thresholding function: a neuron’s state is either “active” or “not active”, and
        at each neural computation step, this state is determined by calculating the weighted
        sum of the states of all the afferent neurons that connect to the neuron. For this
        purpose, connections between neurons are directed (from neuron Ni
        to neuron Nj), and have a weight (wi j). If the weighted sum of the states of all the neurons Ni
        connected to a neuron Nj exceeds the characteristic threshold of Nj
        , the state of Nj is set to active, otherwise it is not   [Computing with Spiking NNs]



  II.   Continuous activation

    do not use a step- or threshold function to compute their output signals, but a
    continuous activation function, making them suitable for
    analog in- and output

    Commonly used examples of activation functions are the sigmoid and hyperbolic tangent

    Typical examples of neural networks consisting of neurons of these types are feed-forward and recurrent neural networks. 

    


  III.  Spiking NNs
  
    Networks which employ spiking neurons
    as computational units, taking into account the precise firing times of neurons
    for information coding
  
  
2 . Neural Networks - Biological Background and Artificial State-of-the-art


3 . Evolutionary Spiking Neural Networks
  
* SNNs are sometimes referred to as Pulsed-Coupled Neural Networks (PCNNs) in literature

4 . Structure and Implementation of the eSNN classifier

5 . Conclusions & Next steps

A . Appendix

B . Bibliography

  1 Maass, W. The Third Generation of Neural Network Models, Technische Universität Graz (1997)



