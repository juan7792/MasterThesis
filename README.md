# MasterThesis
The codes were written in MATLAB R2019b using the Statistics and Machine Learning Toolbox. The functions are part of the methodology used to apply statistical and probabilistic approaches to develop a Bayesian network. The computation of the conditional probability tables were computed using the expectation-maximization algorithm in GeNIe Modeler 2.4.


## Summary

### Files

#### 1) statistical_parameters_eff_sand.m
This file computes the mean value, standard deviation and coefficient of variance of the input data set (eff_sand.mat). The summary of the computations are stored in a table 
(matlab_statistical_parameters.xlsx).

#### 2) correlations_ant_sand.m
This code takes the input data sets (eff_ant.mat, eff_sand.mat and do_consump.mat) to compute the correlation coefficient between the variables and generate the scatter plots of 
one data set versus the other. The correlation coefficients are stored in a table (matlab_correlations_ant_sand.xlsx).

#### 3) distribution_fittings_eff_sand.m
Different probability models are fitted to the input data set (eff_sand.mat) and the maximum likelihood estimator is computed. The results of the latter are stored in a table 
(matlab_distribution_fittings_eff_sand.xlsx).

#### 4) gen_samples_sand.m
Using the most suitable probability distributions for the variable, random samples are generated applying the Nataf transformation to model the correlation between the variable using a Gaussian copula. The generated random samples are then stored in an excel file (samples_sand.xlsx).

#### 5) bn_final_thesis.xdsl
The computations of the Bayesian network are made with this file, corresponding to the software GeNIe. This file receives the input data from samples_sand.xlsx and computes the conditional probability tables of the network using the Expectation-Maximization algorithm. Further analysis of the network are done with this file in GeNIe.
