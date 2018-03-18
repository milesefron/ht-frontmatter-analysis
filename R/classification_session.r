library(caret)
library(e1071)

x = read.csv("./data/training_data.csv", sep=" ", header=T)
x = x[,-c(1,2)]

train_index = createDataPartition(x$target, p=0.8, list=FALSE)
x.train = x[train_index,]
x.test  = x[-train_index,]

control = trainControl(method="cv", number=10)
metric = "Accuracy"

fit.lda = train(target~., data=x.train, method="lda", metric=metric, trControl=control)
fit.cart = train(target~., data=x.train, method="rpart", metric=metric, trControl=control) 
fit.lr  = train(target~., data=x.train, method="glm", family="binomial", metric=metric, trControl=control)
fit.svm = train(target~., data=x.train, method="svmRadial", metric=metric, trControl=control) 
fit.rf = train(target~., data=x.train, method="rf", metric=metric, trControl=control)
fit.knn = train(target~., data=x.train, method="knn", metric=metric, trControl=control) 

results = resamples(list(lda=fit.lda, cart=fit.cart, lr=fit.lr, knn=fit.knn, svm=fit.svm, rf=fit.rf)) 

summary(results)
dotplot(results)

predictions = predict(fit.rf, x.test)
confusionMatrix(predictions, x.test$target)


n = c(100, 250, 500, 1000, 2500, 5000, 7500, 10000, 15000, 24214)
a = vector()
for(i in 1:length(n)) {
	x.sample = x.train[sample(nrow(x.train), n[i]),]
	#fit.lr  = train(target~., data=x.sample, method="glm", family="binomial", metric=metric, trControl=control)
	fit.knn = train(target~., data=x.sample, method="knn", metric=metric, trControl=control)
	predictions = predict(fit.knn, x.test)
	cm = confusionMatrix(predictions, x.test$target)
	a[i] = as.numeric(cm[3]$overall[1])
}
plot(cbind(n,a), type="b", xlab="Training Instances (# Pages)", ylab="Model Accuracy")

filterControl = sbfControl(functions=rfSBF, method="repeatedCV", repeats=5)
set.seed(7)
fbWithFiler = sbf(x[,1:11], x$target, sbfControl=filterControl)


