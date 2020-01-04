
library(readxl)
mydf<- read_excel("german credit card.xls")
View(mydf)
#rub data, replace missing values X
mydf$purpose_num<-as.numeric(replace(mydf$purpose, "", "X"))[1:1000]

#rub data, transform good_bad to 1&0 and numeric
mydf$good_bad<-gsub(mydf$good_bad,pattern='good',replacement=1)
mydf$good_bad<-gsub(mydf$good_bad,pattern='bad',replacement=0)

mydf$good_bad<-as.numeric(mydf$good_bad)

#subset good bad
mydf_good <- mydf[which(mydf$good_bad == 1),c('checking','duration')]
mydf_bad <- mydf[which(mydf$good_bad == 0),1:2]

#single variable regression
my_ger<-glm(good_bad~age,data=mydf,family = 'binomial')
summary(my_ger)
 
#age is significant
exp(0.01844)-1 
#for every age increase, odds of being good creditor increase by 1.8%

#prob for 45 yr old person has good credit?
age2cred <- function(inter, beta1, age)  {
  logit <- inter +beta1*age
  odds <-exp(logit)
  prob <- odds/(1+odds)
  return(c(odds,prob))
}
age2cred(inter=0.200919,beta1=0.018440,age=45)
#insight: for a customer who is 45 yr old, the probability of having a good credit is 73.7%
age2cred(inter=0.200919,beta1=0.018440,age=50)
#insight: for a customer who is 50 yr old, the probability of having a good credit is 75.5%

#lets split our german credit data for training and testing using random sampling
train_index <- sample(1:nrow(mydf), size=600)
test_index <- c(1:nrow(mydf))[-train_index]
gc_train <- mydf[train_index,]
gc_test <- mydf[test_index,]

#Creating one variable logistic regression
my_mod <- glm(good_bad~age,data=gc_train,family = 'binomial')
summary(my_mod)

#using the model to predict the 1/0 var in the test dataset
predict(my_mod, gc_test, type='response')

# a model with more variables
my_ger_bigger <- glm(good_bad~age+amount+duration+savings+telephon,data=gc_train, family="binomial")
summary(my_ger_bigger)
#remove amount, telephon, the irrelevant factors

#build the smallest medium residual models, to build the best model for ger_cre
my_ger_bigger <- glm(good_bad~checking+history+duration+installp+marital+other+savings,data=mydf, family="binomial")
summary(my_ger_bigger)
#0.4588 is the smallest medium residual

#test for if my data is homostatistic or heterostatistic
plot(mydf$amount,mtdf$age)  
#the plot cannot be fitted by one line, but can be fitted using quartile regression
install.packages('quantreg')
library(quantreg)

rq_model<-rq(amount~age, data = mydf, tau=0.2) # tau<- quartile, around 25 yr
summary(rq_model)  # b1=-0.52
rq_model<-rq(amount~age, data = mydf, tau=0.5) #50th quartile, around 40 yr
summary(rq_model)  # b1=-1.28
rq_model<-rq(amount~age, data = mydf, tau=0.9) #90th quartile, around 75 yr
summary(rq_model)  # b1=24.92, this is the most important quartile
#Insight: for young customers in low quantiles, every year increase in age is
# accompanied by decrease in amount. However, when an older customers gets 
# older by 1 year, amount shoots up by $25. 

#run one line of best fit
lin_bad <- lm(amount~age, data = mydf)
summary(lin_bad)  #b1=8.1, one line does not fit all

library(rpart)
library(rpart.plot)
library(ROCR)
ger_tree <- rpart(good_bad~age+amount+duration+checking,data=mydf,method='class')
rpart.plot(ger_tree,extra=1,type=1)
ger_logit <-glm(good_bad~age+duration+checking,data=mydf,family='binomial')
summary(ger_logit)
# compare models:
#Decision tree: 
# 1. amount is not the most important, but it matters after checking and duration
# 2. age doesn't matter
#Logistic: 
# 1. amount does not matter
# 2. age is a significant variable

#check how data insight relate to model performance
predict_tree<-predict(ger_tree,mydf,type='prob')
predict_logit<-predict(ger_logit,mydf,type='response')
predict_val_tree<-prediction(predict_tree[,2],mydf$good_bad) 
# [,2] the second variable bc we have a dataframe with 2 variables, prob 0 and 1. 1 is the success.
predict_val_logit<-prediction(predict_logit,mydf$good_bad)

perf_tree<-performance(predict_val_tree,'tpr','fpr')
perf_logit<-performance(predict_val_logit,'tpr','fpr')
plot(perf_tree,col='black')
plot(perf_logit,col='red',add=T)
#both models are good. Where false positive rate is lower, the logistic model is 
#better. For high false rate, the decision tree is better. Typically, 
# we are interested in low false positive rate so the logistic model wins.