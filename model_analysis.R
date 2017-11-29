library("randomForest")
library("llama")

model <- readRDS("models/unlabelled.rds")
forest <- model[["models"]][[1]][["learner.model"]]

# From random forest

plot(forest, main = "")
legend("topright", c("OOB", "clique", "k\u2193", "McSplit", "McSplit\u2193"), fill = 1:5, xpd = TRUE)

importance <- importance(forest)
graph_feature_names <- c("vertices", "edges", "loops", "mean degree", "max degree", "SD of degrees", "density", "connected", "mean distance", "max distance", "distance \u2265 2", "distance \u2265 3", "distance \u2265 4")
selected_features <- c("vertices", "edges", "mean degree", "max degree", "density", "mean distance", "max distance")
full_feature_names <- c(paste("pattern", graph_feature_names), paste("target", graph_feature_names), paste(selected_features, "ratio"))
row.names(importance) <- full_feature_names
dotchart(sort(importance[,1]), xlab = "Mean decrease in Gini index")

partialPlot(forest, data[["data"]], "target.stddeg", ...)
varUsed(forest)
plot(margin(forest))
MDSplot(forest) # with classCenter?
treesize(forest)

mean(parscores(data, model))
mean(parscores(data, vbs))
mean(parscores(data, singleBest))
