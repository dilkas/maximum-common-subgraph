library("randomForest")
library("llama")

model <- readRDS("models/unlabelled_proximity.rds")
forest <- model[["models"]][[1]][["learner.model"]]
rm("model")
# TODO: load data, figure out how to run the following:

MDSplot(forest)
outlier(forest)
