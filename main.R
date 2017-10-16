require(llama)

features <- read.csv("results/sip_features.csv", header = FALSE)
#data = input(read.csv("features.csv"), read.csv("times.csv"))
data(satsolvers)
data = satsolvers

folds = cvFolds(data)
model = classify(makeLearner("classif.randomForest"), folds)

mean(misclassificationPenalties(data, vbs))
mean(misclassificationPenalties(folds, model))
mean(misclassificationPenalties(data, singleBest))
