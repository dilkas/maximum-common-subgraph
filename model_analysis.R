library("randomForest")
library("llama")

model <- readRDS("models/unlabelled.rds")
forest <- model[["models"]][[1]][["learner.model"]]
rm("model")

graph_feature_names <- c("vertices", "edges", "loops", "mean degree", "max degree", "SD of degrees", "density", "connected", "mean distance", "max distance", "distance \u2265 2", "distance \u2265 3", "distance \u2265 4")
selected_features <- c("vertices", "edges", "mean degree", "max degree", "density", "mean distance", "max distance")
full_feature_names <- c(paste("pattern", graph_feature_names), paste("target", graph_feature_names), paste(selected_features, "ratio"))
rm("graph_feature_names", "selected_features")

# From random forest

png("images/unlabelled_forest_errors.png", width = 440, height = 388)
plot(forest, main = "")
legend("topright", c("OOB", "clique", "k\u2193", "McSplit", "McSplit\u2193"), fill = 1:5, xpd = TRUE)
dev.off()

importance <- importance(forest)
row.names(importance) <- full_feature_names
png("images/unlabelled_variable_importance.png", width = 440, height = 388)
dotchart(sort(importance[,1]), xlab = "Mean decrease in Gini index")
dev.off()
rm("importance")

png("images/unlabelled_var_used.png", width = 440, height = 388)
par(mar = c(0, 10, 0, 5))
barplot(sort(setNames(varUsed(forest), full_feature_names)), las = 2, horiz = TRUE)
dev.off()

png("images/tree_sizes.png", width = 440, height = 388)
hist(treesize(forest), main = "", xlab = "tree size")
dev.off()

margin <- margin(forest)
png("images/unlabelled_margin.png", width = 440, height = 388)
plot(margin)
dev.off()
png("images/unlabelled_margin2.png", width = 440, height = 388)
plot(margin, sort = FALSE)
dev.off()
png("images/clique_hist.png", width = 440, height = 388)
hist(subset(margin, attr(margin, "names") == "clique"), main = "clique", xlab = "margin")
dev.off()
png("images/kdown_hist.png", width = 440, height = 388)
hist(subset(margin, attr(margin, "names") == "kdown"), main = "k\u2193", xlab = "margin")
dev.off()
png("images/mcsplit_hist.png", width = 440, height = 388)
hist(subset(margin, attr(margin, "names") == "mcsplit"), main = "McSplit", xlab = "margin")
dev.off()
png("images/mcsplitdown_hist.png", width = 440, height = 388)
hist(subset(margin, attr(margin, "names") == "mcsplitdown"), main = "McSplit\u2193", xlab = "margin")
dev.off()

# TODO: decide on these later
#partialPlot(forest, data[["data"]], "target.stddeg", "mcsplitdown", main = "McSplit\u2193", xlab = "target SD of degrees")
#partialPlot(forest, data[["data"]], "target.stddeg", "clique", main = "McSplit", xlab = "target SD of degrees")

# </randomForest> <llama>

#sum(successes(data, model))
#sum(successes(data, vbs, addCosts = FALSE))
#sum(misclassificationPenalties(data, model))
#sum(parscores(data, model))
#mean(parscores(data, model))
#mean(parscores(data, vbs))
#mean(parscores(data, singleBest))
#contributions(data)
