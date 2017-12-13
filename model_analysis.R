library("randomForest")
library("llama")

model <- readRDS("models/unlabelled.rds")
forest <- model[["models"]][[1]][["learner.model"]]

graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
                         "max degree", "SD of degrees", "density", "connected",
                         "mean distance", "max distance", "distance \u2265 2",
                         "distance \u2265 3", "distance \u2265 4")
selected_features <- c("vertices", "edges", "mean degree", "max degree",
                       "density", "mean distance", "max distance")
full_feature_names <- c(paste("pattern", graph_feature_names),
                        paste("target", graph_feature_names),
                        paste(selected_features, "ratio"))
rm("graph_feature_names", "selected_features")

# From random forest

png("dissertation/images/unlabelled_forest_errors.png", width = 446,
    height = 288)
plot(forest, main = "")
legend("right", c("OOB", "clique", "k\u2193", "McSplit", "McSplit\u2193"),
       fill = 1:5, xpd = TRUE)
dev.off()

importance <- importance(forest)
row.names(importance) <- full_feature_names
png("dissertation/images/unlabelled_variable_importance.png", width = 446,
    height = 526)
dotchart(sort(importance[,1]), xlab = "Mean decrease in Gini index")
dev.off()
rm("importance")

png("dissertation/images/unlabelled_var_used.png", width = 446, height = 526)
par(mar = c(0, 10, 0, 5))
barplot(sort(setNames(varUsed(forest), full_feature_names)), las = 2,
        horiz = TRUE)
dev.off()

png("dissertation/images/tree_sizes.png", width = 446, height = 288)
hist(treesize(forest), main = "", xlab = "tree size")
dev.off()

margin <- margin(forest)
png("dissertation/images/unlabelled_margin.png", width = 446, height = 288)
plot(margin, ylab = "margin")
dev.off()
png("dissertation/images/unlabelled_margin2.png", width = 446, height = 288)
plot(margin, sort = FALSE, ylab = "margin")
dev.off()
png("dissertation/images/clique_hist.png", width = 446, height = 288)
hist(subset(margin, attr(margin, "names") == "clique"), main = "clique",
     xlab = "margin")
dev.off()
png("dissertation/images/kdown_hist.png", width = 446, height = 288)
hist(subset(margin, attr(margin, "names") == "kdown"), main = "k\u2193",
     xlab = "margin")
dev.off()
png("dissertation/images/mcsplit_hist.png", width = 446, height = 288)
hist(subset(margin, attr(margin, "names") == "mcsplit"), main = "McSplit",
     xlab = "margin")
dev.off()
png("dissertation/images/mcsplitdown_hist.png", width = 446, height = 288)
hist(subset(margin, attr(margin, "names") == "mcsplitdown"),
     main = "McSplit\u2193", xlab = "margin")
dev.off()
rm("margin")

data <- readRDS("models/unlabelled_data.rds")
png("dissertation/images/mcsplit_partial.png", width = 446, height = 288)
partialPlot(forest, data[["data"]], "target.stddeg", "mcsplit",
            main = "McSplit\u2193", xlab = "target SD of degrees")
dev.off()
png("dissertation/images/clique_partial.png", width = 446, height = 288)
partialPlot(forest, data[["data"]], "target.stddeg", "clique", main = "clique",
            xlab = "target SD of degrees")
dev.off()

# ECDF

library(lattice)
library(latticeExtra)

costs <- read.csv("results/costs.csv", header = FALSE)
colnames(costs) <- c("ID", "cost")
labels <- c("McSplit\u2193", "Llama", "VBS")

times <- subset(data$data, T, c("ID", data$performance))
times$vbs <- apply(times[,-1], 1, min)
winning_algorithms <- model$predictions[model$predictions$score == 1,
                                        c("ID", "algorithm")]
winning_algorithms$algorithm <- unlist(
  lapply(winning_algorithms$algorithm, function(x) which(colnames(times) == x)))
times <- merge(times, winning_algorithms, by = "ID", all.x = TRUE)
times$llama <- as.numeric(times[cbind(seq_along(times$algorithm),
                                      times$algorithm)])
times <- merge(times, costs, by = c("ID"), all.x = TRUE)
times$llama <- times$llama + times$cost

#summary(times$llama < times$mcsplitdown)
# how often each algorithm was predicted
#summary(model$predictions$algorithm[model$predictions$score == 1])
#summary(as.factor(unlist(data$best))) # how often each algorithm won
png("dissertation/images/ecdf_unlabelled_llama.png", width = 446, height = 288)
ecdfplot(~ mcsplitdown + llama + vbs, data = times,
         auto.key = list(space = "right", text = labels), xlab = "Runtime (ms)",
         ylim = c(0.8, 1))
dev.off()

# llama metrics

library(ggplot2)
#sum(successes(data, model))
#sum(successes(data, vbs))
#sum(successes(data, singleBest))
#sum(misclassificationPenalties(data, model))
#mean(parscores(data, model))
#mean(parscores(data, vbs))
#mean(parscores(data, singleBest))
#contributions(data)
#png("dissertation/images/unlabelled_scatterplot1.png", width = 446,
#    height = 288)
#perfScatterPlot(parscores, model, vbs, cvFolds(data, stratify = TRUE), data) + xlab("Llama") + ylab("VBS")
#dev.off()
#png("dissertation/images/unlabelled_scatterplot2.png", width = 446,
#    height = 288)
#(perfScatterPlot(parscores, model, singleBest, data) + xlab("Llama") +
#    ylab("McSplit\u2193"))
#dev.off()
