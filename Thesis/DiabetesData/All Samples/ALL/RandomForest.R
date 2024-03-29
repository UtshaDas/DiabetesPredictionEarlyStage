library(randomForest)
library(pROC)
trainDF<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/All Samples/ALL/Diabetes_Dataset_Train80p.csv")
testDF<-read.csv("C:/Users/BREB/OneDrive/Documents/MSc Thesis/Thesis/DiabetesData/All Samples/ALL/Diabetes_Dataset_Test20p.csv")

trainDF$class<-as.factor(trainDF$class)
testDF$class<-as.factor(testDF$class)

bestmtry<-tuneRF(trainDF,as.factor(trainDF$class),ntreeTry = 100,stepFactor = 1.2,
                 improve = 0.01,trace = TRUE,plot = TRUE, doBest=TRUE)

modelRandom<-randomForest(class~.,data = trainDF,mtry=bestmtry$mtry,ntree=bestmtry$ntree) 
#print(importance(modelRandom))
#varImpPlot(modelRandom)
PredictionsWithClass<- predict(modelRandom, testDF[,1:16], type = 'class')
cm<-table(predictions=PredictionsWithClass, actual=testDF$class)

acc=((sum(diag(cm))/sum(cm)))
tp<-cm[2,2]
tn<-cm[1,1]
fn<-cm[1,2]
fp<-cm[2,1]

sen=tp/(tp+fn)
spe=tn/(tn+fp)
mcc=((tp*tn) - (fp*fn))/(sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn)))
f1=2*tp/((2*tp)+fp+fn)

roc_obj<-roc(testDF$class,as.numeric(PredictionsWithClass))
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