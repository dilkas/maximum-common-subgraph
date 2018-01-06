library(randomForest)
library(llama)
library(RColorBrewer)
library(lattice)
library(latticeExtra)

type <- "vertex_labels"
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
# 
# png(paste0("dissertation/images/", type, "_forest_errors.png"), width = 446,
#     height = 288)
# plot(forest, main = "")
# legend("right", c("OOB", "clique", "McSplit", "McSplit\u2193"),
#        fill = 1:4, xpd = TRUE)
# dev.off()
# 
# importance <- importance(forest)
# row.names(importance) <- full_feature_names
# png(paste0("dissertation/images/", type, "_variable_importance.png"),
#     width = 446, height = 526)
# dotchart(sort(importance[,1]), xlab = "Mean decrease in Gini index")
# dev.off()
# rm("importance")
# 
# png(paste0("dissertation/images/", type, "_var_used.png"), width = 446,
#     height = 526)
# par(mar = c(0, 10, 0, 5))
# barplot(sort(setNames(varUsed(forest), full_feature_names)), las = 2,
#         horiz = TRUE)
# dev.off()
# 
# png(paste0("dissertation/images/", type, "tree_sizes.png"), width = 446,
#     height = 288)
# hist(treesize(forest), main = "", xlab = "tree size")
# dev.off()
# 
# margin <- margin(forest)
# png(paste0("dissertation/images/", type, "_margin.png"), width = 446,
#     height = 288)
# plot(margin, ylab = "margin")
# legend("bottomright", c("clique", "k\u2193", "McSplit", "McSplit\u2193"),
#        fill = brewer.pal(4, "Set1"))
# dev.off()
# png(paste0("dissertation/images/", type, "_margin2.png"), width = 446,
#     height = 288)
# plot(margin, sort = FALSE, ylab = "margin")
# dev.off()
# png(paste0("dissertation/images/", type, "_clique_hist.png"), width = 446,
#     height = 288)
# hist(subset(margin, attr(margin, "names") == "clique"), main = "clique",
#      xlab = "margin")
# dev.off()
# #png(paste0("dissertation/images/", type, "_kdown_hist.png"), width = 446,
# #    height = 288)
# #hist(subset(margin, attr(margin, "names") == "kdown"), main = "k\u2193",
# #     xlab = "margin")
# #dev.off()
# png(paste0("dissertation/images/", type, "_mcsplit_hist.png"), width = 446,
#     height = 288)
# hist(subset(margin, attr(margin, "names") == "mcsplit"), main = "McSplit",
#      xlab = "margin")
# dev.off()
# png(paste0("dissertation/images/", type, "_mcsplitdown_hist.png"), width = 446,
#     height = 288)
# hist(subset(margin, attr(margin, "names") == "mcsplitdown"),
#      main = "McSplit\u2193", xlab = "margin")
# dev.off()
# rm("margin")

# Partial dependence plots

algorithms <- c("clique", "mcsplit", "mcsplitdown")
algorithm_labels <- c("clique", "McSplit", "McSplit\u2193")
features <- c("labelling", "target.stddeg")
feature_labels <- c("Labelling (%)", "Target SD of degrees")
for (i in 1:length(algorithms)) {
  for (j in 1:length(features)) {
    png(paste("dissertation/images/", type, algorithms[i], features[j], ".png",
              sep = "_"), width = 446, height = 288)
    partialPlot(forest, data[["data"]], features[j], algorithms[i],
                main = algorithm_labels[i], xlab = feature_labels[j])
    dev.off()
  }
}

# ECDF
# 
# filtered_instances <- readLines("results/filtered_instances")
# costs <- read.csv("results/costs.csv", header = FALSE)
# colnames(costs) <- c("ID", "cost")
# costs <- subset(costs, costs$ID %in% filtered_instances)
# costs <- costs[rep(seq_len(nrow(costs)), each = length(p_values)),]
# costs$labelling <- p_values
# costs$ID <- sprintf("%02d %s", costs$labelling, costs$ID)
# costs <- costs[, c("ID", "cost")]
# 
# labels <- c("clique", "McSplit", "McSplit\u2193", "VBS", "Llama")
# times <- subset(data$data, T, c("ID", data$performance))
# times$vbs <- apply(times[,-1], 1, min)
# winning_algorithms <- model$predictions[model$predictions$score == 1,
#                                         c("ID", "algorithm")]
# winning_algorithms$algorithm <- unlist(
#   lapply(winning_algorithms$algorithm,
#          function(x) which(colnames(times) == x)))
# times <- merge(times, winning_algorithms, by = "ID", all.x = TRUE)
# times$llama <- as.numeric(times[cbind(seq_along(times$algorithm),
#                                       times$algorithm)])
# times <- merge(times, costs, by = c("ID"), all.x = TRUE)
# times$llama <- times$llama + times$cost

#summary(times$llama < times$clique)
# how often each algorithm was predicted
#summary(model$predictions$algorithm[model$predictions$score == 1])
#summary(as.factor(unlist(data$best))) # how often each algorithm won
# 
# png(paste0("dissertation/images/ecdf_", type, "_llama.png"), width = 446,
#     height = 288)
# plt <- ecdfplot(~ clique + mcsplit + mcsplitdown + vbs + llama, data = times,
#                 auto.key = list(space = "right", text = labels),
#                 xlab = "Runtime (ms)", ylim = c(0.9, 1))
# update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8, name = "Dark2")))
# dev.off()

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
# 
# times <- subset(data$data, T, data$performance)
# times$vbs <- apply(times, 1, min)
# cols <- gray(seq(1, 0, length.out = 255))
# labels <- c("clique", "McSplit", sprintf('McSplit\u2193'), "VBS")
# #summary(as.factor(unlist(data[["best"]])))
# 
# png(paste0("dissertation/images/ecdf_", type, ".png"), width = 446,
#     height = 288)
# plt <- ecdfplot(~ clique + mcsplit + mcsplitdown + vbs, data = times,
#                 auto.key = list(space = "right", text = labels),
#                 xlab = "Runtime (ms)", ylim = c(0.9, 1))
# update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8,
#                                                           name = "Dark2")))
# dev.off()
# 
# # Number of instances solved
# algorithms <- c("clique", "mcsplit", "mcsplitdown")
# colours <- rainbow(length(algorithms))
# solved <- expand.grid(algorithm = algorithms, labelling = p_values)
# solved$proportion <- apply(solved, 1, function(row)
#   sum(data[["data"]]$labelling == as.numeric(row[2])))
# solved$proportion <- apply(solved, 1, function(row)
#   sum(data[["data"]]$labelling == as.numeric(row[2]) &
#         data[["data"]][paste0(row[1], "_success")] == TRUE) /
#     as.numeric(row[3]))
# png(paste0("dissertation/images/", type, "_linechart.png"), width = 446,
#     height = 288)
# plot(range(solved$labelling), range(solved$proportion), xlab = "Labelling (%)",
#      ylab = "Proportion solved", type = "n")
# for (i in 1:length(algorithms)) {
#   individual_results <- subset(solved, solved$algorithm == algorithms[i])
#   lines(individual_results$labelling, individual_results$proportion,
#         col = colours[i])
# }
# legend("bottomright", c("clique", "McSplit", "McSplit\u2193"), fill = colours)
# dev.off()
# rm("solved")
# 
# cumulative <- expand.grid(algorithm = algorithms, labelling = p_values)
# cumulative$time <- apply(cumulative, 1, function(row)
#   sum(data$data[data$data$labelling == as.numeric(row[2]), row[1]]))
# png(paste0("dissertation/images/", type, "_linechart2.png"), width = 446,
#     height = 288)
# plot(range(cumulative$labelling), range(cumulative$time),
#      xlab = "Labelling (%)", ylab = "Total runtime (ms)", type = "n")
# for (i in 1:length(algorithms)) {
#   individual_results <- subset(cumulative,
#                                cumulative$algorithm == algorithms[i])
#   lines(individual_results$labelling, individual_results$time,
#         col = colours[i])
# }
# legend("topright", c("clique", "McSplit", "McSplit\u2193"), fill = colours)
# dev.off()
# rm("cumulative")
# 
# mins <- data$data[, c("labelling", algorithms)]
# mins$min <- apply(mins[,algorithms], 1, min)
# won <- expand.grid(algorithm = algorithms, labelling = p_values)
# won$count <- apply(won, 1, function(row)
#   sum(mins$labelling == as.numeric(row[2]) & mins[row[1]] == mins$min))
# png(paste0("dissertation/images/", type, "_linechart3.png"), width = 446,
#     height = 288)
# plot(range(won$labelling), range(won$count),
#      xlab = "Labelling (%)", ylab = "Times won", type = "n")
# for (i in 1:length(algorithms)) {
#   individual_results <- subset(won, won$algorithm == algorithms[i])
#   lines(individual_results$labelling, individual_results$count,
#         col = colours[i])
# }
# legend("bottomright", c("clique", "McSplit", "McSplit\u2193"), fill = colours)
# dev.off()
# rm("mins", "won", "individual_results")

# Log runtimes by solver and instance
#png(paste0("dissertation/images/", type, "_runtime_heatmap.png"), width = 446,
#    height = 288)
#image(log10(t(as.matrix(times))), axes = F, col = cols)
#axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance))),
#     las = 2)
#dev.off()

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
#length(which(times$clique <= times$mcsplit & times$clique <= times$mcsplitdown))
#length(which(times$mcsplit <= times$clique & times$mcsplit <= times$mcsplitdown))
#length(which(times$mcsplitdown <= times$clique &
#               times$mcsplitdown <= times$mcsplit))

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
