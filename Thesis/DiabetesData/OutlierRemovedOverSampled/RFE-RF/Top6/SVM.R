rm(list=ls())
training<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/RFE-RF/Top6/Diabetes_Dataset_Train80p.csv")
testing<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/RFE-RF/Top6/Diabetes_Dataset_Test20p.csv")
sapdata<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/RFE-RF/Top6/Sap_SVM_Selected.csv")

seedarray <- c(131,124,451,689,320,420,987,150,489,143,323,550,740,430,303,264,456,970,950,880)
#seedarray <- c(131,124,451,689,320,420,987,150,489,143,640,550,740,250,870,264,456,970,950,880)
# seedarray<-970
accarray<-rep(0,length(seedarray))
senarray<-rep(0,length(seedarray))
spearray<-rep(0,length(seedarray))
mccarray<-rep(0,length(seedarray))
f1array<-rep(0,length(seedarray))
rocaucarray<-rep(0,length(seedarray))
for(i in 1:length(seedarray)){
  
  library(e1071)
  library(pROC)
  
  set.seed(seedarray[i])
  wts <- 100 / table(training$class)
  system.time(svm_tune <- tune(svm, train.x=training[,1:6], train.y=as.factor(training[,7]), 
                               kernel="radial",class.weights = wts,tunecontrol = tune.control(sampling = "cross"), ranges=list(cost=2^(-8:8), gamma=c(2^(-8:8)))))
  
  classifier=svm(formula=factor(class) ~ .,
                 data=training,
                 scale=TRUE,
                 type='C-classification',
                 kernel='radial',
                 
                 cost=svm_tune$best.parameters$cost,
                 gamma=svm_tune$best.parameters$gamma)
  print(classifier)
  y_pred=predict(classifier,newdata=testing[-7])
  #y_pred<-round(y_pred)
  cm=table(y_pred,testing[,7],dnn=c("Prediction","Actual"))
  miscl<-1-sum(diag(cm))/sum(cm)
  print(i)
  print('Accuracy:')
  acc=(1-miscl)
  print(acc)
  accarray[i]<-acc
  tp<-cm[2,2]
  tn<-cm[1,1]
  fn<-cm[1,2]
  fp<-cm[2,1]
  
  sen=tp/(tp+fn)
  spe=tn/(tn+fp)
  mcc=((tp*tn) - (fp*fn))/(sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn)))
  f1=2*tp/((2*tp)+fp+fn)
  senarray[i]<-sen
  spearray[i]<-spe
  mccarray[i]<-mcc
  f1array[i]<-f1
  
  roc_obj<-roc(testing[,7],as.numeric(y_pred))
  rocauc<-auc(roc_obj)
  
  rocaucarray[i]<-rocauc
  
  sapdata[i,1]=seedarray[i]
  sapdata[i,2]=svm_tune$best.parameters$cost
  sapdata[i,3]=svm_tune$best.parameters$gamma
  sapdata[i,4]=acc
  sapdata[i,5]=sen
  sapdata[i,6]=spe
  sapdata[i,7]=mcc
  sapdata[i,8]=f1
  sapdata[i,9]=rocauc
}
write.csv(sapdata,"C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/OutlierRemoved/RFE-RF/Top6/Sap_SVM_Selected.csv")

print('Mean Accuracy')
print(mean(accarray))

print('Standard Deviation')
print(sd(accarray))

print('Mean Sensitivity')
print(mean(senarray))

print('Standard Deviation')
print(sd(senarray))

print('Mean Specificity')
print(mean(spearray))

print('Stanard Deviation')
print(sd(spearray))


print('Mean mcc')
print(mean(mccarray))

print('Stanard Deviation')
print(sd(mccarray))

print('Mean F1')
print(mean(f1array))

print('Stanard Deviation')
print(sd(f1array))

print('Mean Auc')
print(mean(rocaucarray))

print('Stanard Deviation')
print(sd(rocaucarray))
