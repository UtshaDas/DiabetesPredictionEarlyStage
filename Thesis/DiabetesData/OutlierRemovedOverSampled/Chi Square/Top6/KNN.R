rm(list=ls())
library(caret)
library(pROC)
training<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/Chi Square/Top6/Diabetes_Dataset_Train80p.csv")
testing<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/Chi Square/Top6/Diabetes_Dataset_Test20p.csv")
training$class<-as.factor(training$class)
testing$class<-as.factor(testing$class)
knnFit <- train(class ~ ., data = training, method = "knn",
                trControl = trainControl(method = "repeatedcv",
                                         repeats = 5))


print(knnFit)

predicted=predict(knnFit,newdata=testing[-7])

cm=table(predicted,testing[,7],dnn=c("Prediction","Actual"))
acc=((sum(diag(cm))/sum(cm)))
tp<-cm[2,2]
tn<-cm[1,1]
fn<-cm[1,2]
fp<-cm[2,1]

sen=tp/(tp+fn)
spe=tn/(tn+fp)
mcc=((tp*tn) - (fp*fn))/(sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn)))
f1=2*tp/((2*tp)+fp+fn)

roc_obj<-roc(testing[,7],as.numeric(predicted))
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

