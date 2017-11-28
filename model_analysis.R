library("randomForest")
library("llama")

model <- readRDS("models/unlabelled.rds")
forest <- model[["models"]][[1]][["learner.model"]]

# From random forest

layout(matrix(c(1, 2), nrow = 1), widths = c(4, 1))
par(mar = c(5, 4, 4, 0))
plot(forest, main = "", log = "y")
par(mar = c(5, 0, 4, 2))
plot(c(0, 1), type = "n", axes = FALSE, xlab = "", ylab = "")
legend("top", c("OOB", "clique", "k\u2193", "McSplit", "McSplit\u2193"), col = 1:5, cex = 0.8, fill = 1:5)

partialPlot(forest, data[["data"]], "pattern.vertices")
varImpPlot(forest)
varUsed(forest)
importance(forest)
plot(margin(forest))
MDSplot(forest) # with classCenter?
treesize(forest)

mean(parscores(data, model))
mean(parscores(data, vbs))
mean(parscores(data, singleBest))
