library("randomForest")
library("llama")

type <- "both_labels"
p_values <- c(5, 10, 15, 20, 25, 33, 50)

model <- readRDS(paste0("models/", type, ".rds"))
forest <- model[["models"]][[1]][["learner.model"]]
data <- readRDS(paste0("models/", type, "_data.rds"))

graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
                         "max degree", "SD of degrees", "density", "connected",
                         "mean distance", "max distance", "distance \u2265 2",
                         "distance \u2265 3", "distance \u2265 4")
selected_features <- c("vertices", "edges", "mean degree", "max degree",
                       "density", "mean distance", "max distance")
full_feature_names <- c(paste("pattern", graph_feature_names),
                        paste("target", graph_feature_names),
                        paste(selected_features, "ratio"), "labelling")
rm("graph_feature_names", "selected_features")

# From random forest

png(paste0("dissertation/images/", type, "_forest_errors.png"), width = 446,
    height = 288)
plot(forest, main = "")
legend("right", c("OOB", "clique", "McSplit", "McSplit\u2193"),
       fill = 1:4, xpd = TRUE)
dev.off()

importance <- importance(forest)
row.names(importance) <- full_feature_names
png(paste0("dissertation/images/", type, "_variable_importance.png"),
    width = 446, height = 526)
dotchart(sort(importance[,1]), xlab = "Mean decrease in Gini index")
dev.off()
rm("importance")

png(paste0("dissertation/images/", type, "_var_used.png"), width = 446,
    height = 526)
par(mar = c(0, 10, 0, 5))
barplot(sort(setNames(varUsed(forest), full_feature_names)), las = 2,
        horiz = TRUE)
dev.off()

png(paste0("dissertation/images/", type, "tree_sizes.png"), width = 446,
    height = 288)
hist(treesize(forest), main = "", xlab = "tree size")
dev.off()

margin <- margin(forest)
png(paste0("dissertation/images/", type, "_margin.png"), width = 446,
    height = 288)
plot(margin, ylab = "margin")
dev.off()
png(paste0("dissertation/images/", type, "_margin2.png"), width = 446,
    height = 288)
plot(margin, sort = FALSE, ylab = "margin")
dev.off()
png(paste0("dissertation/images/", type, "_clique_hist.png"), width = 446,
    height = 288)
hist(subset(margin, attr(margin, "names") == "clique"), main = "clique",
     xlab = "margin")
dev.off()
#png(paste0("dissertation/images/", type, "_kdown_hist.png"), width = 446,
#    height = 288)
#hist(subset(margin, attr(margin, "names") == "kdown"), main = "k\u2193",
#     xlab = "margin")
#dev.off()
png(paste0("dissertation/images/", type, "_mcsplit_hist.png"), width = 446,
    height = 288)
hist(subset(margin, attr(margin, "names") == "mcsplit"), main = "McSplit",
     xlab = "margin")
dev.off()
png(paste0("dissertation/images/", type, "_mcsplitdown_hist.png"), width = 446,
    height = 288)
hist(subset(margin, attr(margin, "names") == "mcsplitdown"),
     main = "McSplit\u2193", xlab = "margin")
dev.off()
rm("margin")

#png("dissertation/images/mcsplit_partial.png", width = 446, height = 288)
#partialPlot(forest, data[["data"]], "target.stddeg", "mcsplit",
#            main = "McSplit\u2193", xlab = "target SD of degrees")
#dev.off()
#png("dissertation/images/clique_partial.png", width = 446, height = 288)
#partialPlot(forest, data[["data"]], "target.stddeg", "clique", main = "clique",
#            xlab = "target SD of degrees")
#dev.off()

# ECDF

library(lattice)
library(latticeExtra)

#filtered_instances <- readLines("results/filtered_instances")
#costs <- read.csv("results/costs.csv", header = FALSE)
#colnames(costs) <- c("ID", "cost")
#costs <- subset(costs, costs$ID %in% filtered_instances)
#costs <- costs[rep(seq_len(nrow(costs)), each = length(p_values)),]
#costs$labelling <- p_values
#costs$ID <- sprintf("%02d %s", costs$labelling, costs$ID)
#costs <- costs[, c("ID", "cost")]

#labels <- c("clique", "Llama", "VBS")
#times <- subset(data$data, T, c("ID", data$performance))
#times$vbs <- apply(times[,-1], 1, min)
#winning_algorithms <- model$predictions[model$predictions$score == 1,
#                                        c("ID", "algorithm")]
#winning_algorithms$algorithm <- unlist(
#  lapply(winning_algorithms$algorithm,
#         function(x) which(colnames(times) == x)))
#times <- merge(times, winning_algorithms, by = "ID", all.x = TRUE)
#times$llama <- as.numeric(times[cbind(seq_along(times$algorithm),
#                                      times$algorithm)])
#times <- merge(times, costs, by = c("ID"), all.x = TRUE)
#times$llama <- times$llama + times$cost

#summary(times$llama < times$clique)

# how often each algorithm was predicted
#summary(model$predictions$algorithm[model$predictions$score == 1])
#summary(as.factor(unlist(data$best))) # how often each algorithm won

#png("dissertation/images/ecdf_unlabelled_llama.png", width = 446, height = 288)
#ecdfplot(~ clique + llama + vbs, data = times,
#         auto.key = list(space = "right", text = labels), xlab = "Runtime (ms)",
#         ylim = c(0.9, 1))
#dev.off()

# llama metrics

#library(ggplot2)
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

# Runtime plots

times <- subset(data$data, T, data$performance)
times$vbs <- apply(times, 1, min)
cols <- gray(seq(1, 0, length.out = 255))
labels <- c("clique", "McSplit", sprintf('McSplit\u2193'), "VBS")
#summary(as.factor(unlist(data[["best"]])))

png(paste0("dissertation/images/ecdf_", type, ".png"), width = 446,
    height = 288)
ecdfplot(~ clique + mcsplit + mcsplitdown + vbs, data = times,
         auto.key = list(space = "right", text = labels), xlab = "Runtime (ms)")
dev.off()

# Log runtimes by solver and instance
png(paste0("dissertation/images/", type, "_runtime_heatmap.png"), width = 446,
    height = 288)
image(log10(t(as.matrix(times))), axes = F, col = cols)
axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance))),
     las = 2)
dev.off()

# White - first, black - last (weird results because of equal timing out values)
#image(apply(times , 1, order), axes = F, col = cols)
#axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance) - 1)), las = 2)

# Tables for best algorithms
#times <- performance[grep("data/sip-instances/images-CVIU11", performance$ID), ]
#times <- performance[grep("data/sip-instances/images-PR15", performance$ID), ]
#times <- performance[grep("data/sip-instances/largerGraphs", performance$ID), ]
#times <- performance[grep("data/sip-instances/LV", performance$ID), ]
#times <- performance[grep("data/sip-instances/meshes-CVIU11", performance$ID), ]
#times <- performance[grep("data/sip-instances/phase", performance$ID), ]
#times <- performance[grep("data/sip-instances/scalefree", performance$ID), ]
#times <- performance[grep("data/sip-instances/si", performance$ID), ]
#times <- performance[grep("data/mcs-instances", performance$ID), ]

# How many times is each algorithm the best?
#times = performance
#length(which(times$clique < times$kdown & times$clique < times$mcsplit &
#               times$clique < times$mcsplitdown))
#length(which(times$kdown < times$clique & times$kdown < times$mcsplit &
#               times$kdown < times$mcsplitdown))
#length(which(times$mcsplit < times$clique & times$mcsplit < times$kdown &
#               times$mcsplit < times$mcsplitdown))
#length(which(times$mcsplitdown < times$clique &
#               times$mcsplitdown < times$kdown &
#               times$mcsplitdown < times$mcsplit))

#summary(times[!(times$clique < times$kdown & times$clique < times$mcsplit &
#                  times$clique < times$mcsplitdown) &
#                !(times$kdown < times$clique & times$kdown < times$mcsplit &
#                    times$kdown < times$mcsplitdown) &
#                !(times$mcsplit < times$clique & times$mcsplit < times$kdown &
#                    times$mcsplit < times$mcsplitdown) &
#                !(times$mcsplitdown < times$clique &
#                    times$mcsplitdown < times$kdown &
#                    times$mcsplitdown < times$mcsplit), ])

# Heatmaps for pattern/target features. Group differently?
#features <- subset(data$data, T, data$features)
#nFeatures <- normalize(features)
#graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
#                         "max degree", "SD of degrees", "density", "connected",
#                         "mean distance", "max distance", "distance \u2265 2",
#                         "distance \u2265 3", "distance \u2265 4")
#full_feature_names <- c(paste("pattern", graph_feature_names),
#                        paste("target", graph_feature_names))
#par(mar = c(1, 10, 1, 1))
#image(as.matrix(nFeatures$features), axes = F, col = cols)
#axis(2, labels = full_feature_names,
#     at = seq(0, 1, 1/(length(data$features) - 1)), las = 2)
