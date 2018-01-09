library(randomForest)
library(llama)
library(RColorBrewer)
library(lattice)
library(latticeExtra)

type <- "vertex_labels"
type_label <- "Vertex labels"
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

#png(paste0("dissertation/images/", type, "_forest_errors.png"), width = 480,
#    height = 320)
#plot(forest, main = type_label)
#legend("right", c("OOB", "clique", "McSplit", "McSplit\u2193"),
#       fill = 1:4, xpd = TRUE)
#dev.off()
# 
# importance <- importance(forest)
# row.names(importance) <- full_feature_names
# png(paste0("dissertation/images/", type, "_variable_importance.png"),
#     width = 480, height = 640)
# dotchart(sort(importance[,1]), xlab = "Mean decrease in Gini index", main = type_label)
# dev.off()
# rm("importance")
# 
# png(paste0("dissertation/images/", type, "_var_used.png"), width = 480,
#     height = 640)
# par(mar = c(0, 10, 5, 5))
# barplot(sort(setNames(varUsed(forest), full_feature_names)), las = 2,
#         horiz = TRUE, main = type_label)
# dev.off()
# 

#trees <- data.frame(type = "unlabelled", size = unlabelled)
#trees <- rbind(trees, data.frame(type = "vertex", size = vertex))
#trees <- rbind(trees, data.frame(type = "both", size = both))
#boxplot(size ~ type, data = trees)
# 
# margin <- margin(forest)
# png(paste0("dissertation/images/", type, "_margin.png"), width = 480,
#     height = 320)
# plot(margin, ylab = "Margin", main = paste0(type_label, " (sorted)"))
# legend("bottomright", c("clique", "McSplit", "McSplit\u2193"),
#        fill = brewer.pal(4, "Set1"))
# dev.off()
# png(paste0("dissertation/images/", type, "_margin2.png"), width = 480,
#     height = 320)
# plot(margin, sort = FALSE, ylab = "Margin", main = paste0(type_label, " (unsorted)"))
# dev.off()
# 
# png(paste0("dissertation/images/", type, "_clique_hist.png"), width = 480,
#     height = 320)
# hist(subset(margin, attr(margin, "names") == "clique"), main = paste0(type_label, ", clique"),
#      xlab = "Margin")
# dev.off()
#png(paste0("dissertation/images/", type, "_kdown_hist.png"), width = 480,
#    height = 320)
#hist(subset(margin, attr(margin, "names") == "kdown"), main = "k\u2193",
#     xlab = "margin")
#dev.off()
# png(paste0("dissertation/images/", type, "_mcsplit_hist.png"), width = 480,
#     height = 320)
# hist(subset(margin, attr(margin, "names") == "mcsplit"), main = paste0(type_label, ", McSplit"),
#      xlab = "Margin")
# dev.off()
# png(paste0("dissertation/images/", type, "_mcsplitdown_hist.png"), width = 480,
#     height = 320)
# hist(subset(margin, attr(margin, "names") == "mcsplitdown"),
#      main = paste0(type_label, ", McSplit\u2193"), xlab = "Margin")
# dev.off()
# rm("margin")

# Partial dependence plots

algorithms <- c("clique", "mcsplit", "mcsplitdown")
algorithm_labels <- c("clique", "McSplit", "McSplit\u2193")
features <- c("labelling", "target.stddeg")
feature_labels <- c("Labelling (%)", "Target SD of degrees")
for (j in 1:length(features)) {
  for (i in 1:length(algorithms)) {
    png(paste0("text/dissertation/images/", type, "_", algorithms[i], "_", features[j], ".png"),
	width = 480, height = 320)
    partialPlot(forest, data[["data"]], features[j], algorithms[i],
                main = paste(type_label, algorithm_labels[i], sep = ", "),
                xlab = feature_labels[j], ylab = "Partial dependence")
    dev.off()
  }
}

# ECDF

#filtered_instances <- readLines("results/filtered_instances")
#costs <- read.csv("results/costs.csv", header = FALSE)
#colnames(costs) <- c("ID", "cost")
#costs <- subset(costs, costs$ID %in% filtered_instances)
#costs <- costs[rep(seq_len(nrow(costs)), each = length(p_values)),]
#costs$labelling <- p_values
#costs$ID <- sprintf("%02d %s", costs$labelling, costs$ID)
#costs <- costs[, c("ID", "cost")]

#labels <- c("clique", "k\u2193", "McSplit", "McSplit\u2193", "VBS", "Llama")
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

#summary(times$llama < 10e6)
#summary(times$mcsplitdown < 10e6)
#sum(startsWith(times$ID, "50 "))

#png(paste0("dissertation/images/ecdf_", type, "_llama.png"), width = 480, height = 320)
#plt <- ecdfplot(~ mcsplitdown + vbs + llama, data = times,
#                auto.key = list(space = "right", text = c("McSplit\u2193", "VBS", "Llama")),
#                xlab = "Runtime (ms)", ylim = c(0.9, 1), main = type_label)
#update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8, name = "Dark2")))
#dev.off()
#png(paste0("dissertation/images/ecdf_", type, ".png"), width = 480, height = 320)
#plt <- ecdfplot(~ clique + kdown + mcsplit + mcsplitdown + vbs, data = times,
#                auto.key = list(space = "right", text = labels[-6]),
#                xlab = "Runtime (ms)", ylim = c(0.4, 1), main = type_label)
#update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8, name = "Dark2")))
#dev.off()


#times2 <- times[startsWith(as.character(times$ID), "data/sip-instances/"),]
#times2 <- times[startsWith(as.character(times$ID), "data/mcs-instances/"),]
#png("dissertation/images/ecdf_mcs.png", width = 480, height = 320)
#plt <- ecdfplot(~ clique + kdown + mcsplit + mcsplitdown, data = times2,
#                auto.key = list(space = "right", text = c("clique", "k\u2193", "McSplit", "McSplit\u2193")),
#                xlab = "Runtime (ms)", main = "Unlabelled")
#update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8, name = "Dark2")))
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
#png("dissertation/images/unlabelled_scatterplot1.png", width = 480,
#    height = 320)
#perfScatterPlot(parscores, model, vbs, cvFolds(data, stratify = TRUE), data) + xlab("Llama") + ylab("VBS")
#dev.off()
#png("dissertation/images/unlabelled_scatterplot2.png", width = 480,
#    height = 320)
#(perfScatterPlot(parscores, model, singleBest, data) + xlab("Llama") +
#    ylab("McSplit\u2193"))
#dev.off()

# Line graphs
#algorithms <- c("clique", "mcsplit", "mcsplitdown")
# colours <- rainbow(length(algorithms))
# solved <- expand.grid(algorithm = algorithms, labelling = p_values)
# solved$proportion <- apply(solved, 1, function(row)
#   sum(data[["data"]]$labelling == as.numeric(row[2])))
# solved$proportion <- apply(solved, 1, function(row)
#   sum(data[["data"]]$labelling == as.numeric(row[2]) &
#         data[["data"]][paste0(row[1], "_success")] == TRUE) /
#     as.numeric(row[3]))
# png(paste0("dissertation/images/", type, "_linechart.png"), width = 480,
#     height = 320)
# plot(range(solved$labelling), range(solved$proportion), xlab = "Labelling (%)",
#      ylab = "Proportion solved", type = "n", main = type_label)
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
# png(paste0("dissertation/images/", type, "_linechart2.png"), width = 480,
#     height = 320)
# plot(range(cumulative$labelling), range(cumulative$time),
#      xlab = "Labelling (%)", ylab = "Total runtime (ms)", type = "n", main = type_label)
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
#mins <- data$data[, c("labelling", algorithms)]
#mins$min <- apply(mins[,algorithms], 1, min)
#won <- expand.grid(algorithm = algorithms, labelling = p_values)
#won$count <- apply(won, 1, function(row)
#  sum(mins$labelling == as.numeric(row[2]) & mins[row[1]] == mins$min))
#png(paste0("dissertation/images/", type, "_linechart3.png"), width = 480,
#    height = 320)
#plot(range(won$labelling), range(won$count),
#     xlab = "Labelling (%)", ylab = "Times won", type = "n", main = type_label)
#for (i in 1:length(algorithms)) {
#  individual_results <- subset(won, won$algorithm == algorithms[i])
#  lines(individual_results$labelling, individual_results$count,
#        col = colours[i])
#}
#legend("bottomright", c("clique", "McSplit", "McSplit\u2193"), fill = colours)
#dev.off()
#rm("mins", "won", "individual_results")
#won$count[won$algorithm == "clique" & won$labelling == 50]

# Log runtimes by solver and instance
#png(paste0("dissertation/images/", type, "_runtime_heatmap.png"), width = 480,
#    height = 320)
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
