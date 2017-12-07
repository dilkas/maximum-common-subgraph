library("randomForest")
library("llama")

model <- readRDS("models/unlabelled_proximity.rds")
forest <- model[["models"]][[1]][["learner.model"]]
rm("model")
data <- readRDS("models/data.rds")

png("dissertation/images/mdsplot.png", width = 440, height = 388)
best <- unlist(data[["best"]])
MDSplot(forest, best)
dev.off()
rm("data")

png("dissertation/images/outliers.png", width = 440, height = 388)
plot(outlier(forest), type = "h")
hist(outlier(forest))
dev.off()
