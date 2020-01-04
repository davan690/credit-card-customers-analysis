# credit-card-customers-analysis
In this project, I analyze a dataset of credit card customers using R. 
The external libraries used are rpart, rpart.plot, ROCR, quantreg and readxl.

This study is an exercise to show how to use foundations of Data Science in order to import, study, visualize, and present the raw data in a method that is easy for any user to digest and understand.

Second, a logistic regression is built to determine the likelihood that a Pokemon is legendary, followed by a challenger decision tree model. The result from the decision tree model is visualized, so is the comparison of the two models.

Third, the models will be analyzed, yielding the accurate probability of a Pokemon being legendary.

First, the libraries and the dateset from excel will be loaded into a dataframe. 

Second, the dataset is cleaned, with missing value identification and imputation. The type of data is prepared for analysis.

Then, several models are built to analyze the dataset. A single variable logistic regression is built, followed by a multivariate logistic regression. The model is improved by stratefied sampling. Additionally, I ran a quantile regression to extract insight on customers. Lastly, a challenger decision tree model is built to compare with the logistic model. The tree model is pruned using the optimum cp value. The result from the decision tree model is visualized, so is the comparison of the two models.
