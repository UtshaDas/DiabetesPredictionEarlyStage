rm(list=ls())
library(pROC)
training<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/Chi Square/Top5/Diabetes_Dataset_Train80p.csv")
testing<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/Chi Square/Top5/Diabetes_Dataset_Test20p.csv")

library(caret)
# logit <- glm(target ~ cp+ca+thal, family='binomial', data=training)
# print(summary(logit))
# 
# testing.probs <-predict(logit, testing[,-4], type='response')
# pred.logit <- rep('0',length(testing.probs))
# pred.logit[testing.probs>=0.5] <- '1'
# 
# print(confusionMatrix(factor(pred.logit),factor(testing$target)))
train_control <- trainControl(method = "CV", number = 5)
modelFit<- train(class~.,
                 method='glm',
                 preProcess=c('scale', 'center'), 
                 data=training, 
                 family=binomial(link='logit'),
                 trControl=train_control,
                 tuneGrid=expand.grid(parameter=c(0.001, 0.01, 0.1, 1,10,100, 1000)))

testing$predict <- predict(modelFit, newdata = testing[,-6])
for(i in 1:71)
{
  if (testing[i,7]>=0.5)
    testing[i,7]=1
  else
    testing[i,7]=0
  
}
#print(confusionMatrix(factor(testing$predict),factor(testing$DEATH_EVENT)))

cm=table(testing$predict, testing$class,dnn=c("Prediction","Actual"))

acc=((sum(diag(cm))/sum(cm)))
tp<-cm[2,2]
tn<-cm[1,1]
fn<-cm[1,2]
fp<-cm[2,1]

sen=tp/(tp+fn)
spe=tn/(tn+fp)
mcc=((tp*tn) - (fp*fn))/(sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn)))
f1=2*tp/((2*tp)+fp+fn)

roc_obj<-roc(testing[,6],as.numeric(testing$predict))
rocauc<-auc(roc_obj)

print('Accuracy')
print(acc)
print('sensitivity')
print(sen)
print('Specificity')
print(spe)
print('MCC')
print(mcc)
print('F1')
print(f1)
print('AUC')
print(rocauc)
