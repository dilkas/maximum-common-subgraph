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

par(mar = c(0, 10, 0, 5))
barplot(sort(setNames(varUsed(forest), full_feature_names)), las = 2, horiz = TRUE)
dotchart(sort(setNames(varUsed(forest), full_feature_names)), las = 2)

mean(treesize(forest))
hist(treesize(forest), main = "", xlab = "tree size")

margin <- margin(forest)
plot(margin)
plot(margin, sort = FALSE)
hist(subset(margin, attr(margin, "names") == "clique"), main = "clique", xlab = "margin")
hist(subset(margin, attr(margin, "names") == "kdown"), main = "k\u2193", xlab = "margin")
hist(subset(margin, attr(margin, "names") == "mcsplit"), main = "McSplit", xlab = "margin")
hist(subset(margin, attr(margin, "names") == "mcsplitdown"), main = "McSplit\u2193", xlab = "margin")

partialPlot(forest, data[["data"]], "target.stddeg", "mcsplitdown", main = "McSplit\u2193", xlab = "target SD of degrees")
partialPlot(forest, data[["data"]], "target.stddeg", "clique", main = "McSplit", xlab = "target SD of degrees")

MDSplot(forest)
outlier(forest)

mean(parscores(data, model))
mean(parscores(data, vbs))
mean(parscores(data, singleBest))
