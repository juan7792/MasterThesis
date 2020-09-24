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
