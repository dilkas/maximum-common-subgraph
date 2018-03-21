library(llama)
library(RColorBrewer)
library(lattice)
library(latticeExtra)
library(randomForest)
source("common.R")

type <- "unlabelled" # unlabelled/vertex_labels/both_labels
type_label <- "Unlabelled" # Printing-friendly version of the above
include_fusion <- FALSE # Only compatible with the "both_labels" type

if (type == "unlabelled") {
  algorithms <- c("clique", "kdown", "mcsplit", "mcsplitdown")
  algorithm_labels <- c("clique", "k\u2193", "McSplit", "McSplit\u2193")
  labels <- c("clique", "k\u2193", "McSplit", "McSplit\u2193", "VBS", "Llama")
  costs <- get_costs()
} else {
  algorithms <- c("clique", "mcsplit", "mcsplitdown")
  algorithm_labels <- c("clique", "McSplit", "McSplit\u2193")
  labels <- c("clique", "McSplit", "McSplit\u2193", "VBS", "Llama")
  p_values <- c(5, 10, 15, 20, 25, 33, 50)
  filtered_instances <- readLines("results/filtered_instances")
  costs <- get_costs(filtered_instances, p_values)
}

if (include_fusion) {
  algorithms <- c(algorithms, c("fusion1", "fusion2"))
  algorithm_labels <- c(algorithm_labels, c("Fusion 1", "Fusion 2"))
}

colours <- rainbow(length(algorithms))
model <- readRDS(paste0("models/", type, ".rds"))
forest <- model[["models"]][[1]][["learner.model"]]
data <- readRDS(paste0("models/", type, "_data.rds"))
full_feature_names <- generate_feature_names(type != "unlabelled")

# From random forest

png(paste0("dissertation/images/", type, "_forest_errors.png"), width = 480,
    height = 320)
plot(forest, main = type_label)
legend("right", c("OOB", "clique", "McSplit", "McSplit\u2193"),
       fill = 1:4, xpd = TRUE)
dev.off()

importance <- importance(forest)
row.names(importance) <- full_feature_names
png(paste0("dissertation/images/", type, "_variable_importance.png"),
    width = 480, height = 640)
dotchart(sort(importance[,1]), xlab = "Mean decrease in Gini index", main = type_label)
dev.off()
rm("importance")

png(paste0("dissertation/images/", type, "_var_used.png"), width = 480,
    height = 640)
par(mar = c(0, 10, 5, 5))
barplot(sort(setNames(varUsed(forest), full_feature_names)), las = 2,
        horiz = TRUE, main = type_label)
dev.off()

margin <- margin(forest)
png(paste0("dissertation/images/", type, "_margin.png"), width = 480,
    height = 320)
plot(margin, ylab = "Margin", main = paste0(type_label, " (sorted)"))
legend("bottomright", c("clique", "McSplit", "McSplit\u2193"),
       fill = brewer.pal(4, "Set1"))
dev.off()
png(paste0("dissertation/images/", type, "_margin2.png"), width = 480,
    height = 320)
plot(margin, sort = FALSE, ylab = "Margin",
     main = paste0(type_label, " (unsorted)"))
dev.off()

png(paste0("dissertation/images/", type, "_clique_hist.png"), width = 480,
    height = 320)
hist(subset(margin, attr(margin, "names") == "clique"),
     main = paste0(type_label, ", clique"), xlab = "Margin")
dev.off()
png(paste0("dissertation/images/", type, "_mcsplit_hist.png"), width = 480,
    height = 320)
hist(subset(margin, attr(margin, "names") == "mcsplit"),
     main = paste0(type_label, ", McSplit"), xlab = "Margin")
dev.off()
png(paste0("dissertation/images/", type, "_mcsplitdown_hist.png"), width = 480,
    height = 320)
hist(subset(margin, attr(margin, "names") == "mcsplitdown"),
     main = paste0(type_label, ", McSplit\u2193"), xlab = "Margin")
dev.off()
rm("margin")

# Partial dependence plots

features <- c("labelling", "target.stddeg")
feature_labels <- c("Labelling (%)", "Target SD of degrees")
for (j in 1:length(features)) {
  for (i in 1:length(algorithms)) {
    png(paste0("text/dissertation/images/", type, "_", algorithms[i], "_",
               features[j], ".png"), width = 480, height = 320)
    partialPlot(forest, data$data, features[j], algorithms[i],
                main = paste(type_label, algorithm_labels[i], sep = ", "),
                xlab = feature_labels[j], ylab = "Partial dependence")
    dev.off()
  }
}

# ECDF

times <- subset(data$data, T, c("ID", data$performance))
times$vbs <- apply(times[,-1], 1, min)
winning_algorithms <- model$predictions[model$predictions$score == 1,
                                       c("ID", "algorithm")]
winning_algorithms$algorithm <- unlist(
 lapply(winning_algorithms$algorithm,
        function(x) which(colnames(times) == x)))
times <- merge(times, winning_algorithms, by = "ID", all.x = TRUE)
times$llama <- as.numeric(times[cbind(seq_along(times$algorithm),
                                     times$algorithm)])
times <- merge(times, costs, by = c("ID"), all.x = TRUE)
times$llama <- times$llama + times$group1

# Compile results into a single file
write.csv(times, paste0("results/", type, ".csv"), row.names = FALSE)

if (type == "unlabelled") {
  png(paste0("dissertation/images/ecdf_", type, "_llama.png"), width = 480,
      height = 320)
  plt <- ecdfplot(~ mcsplitdown + vbs + llama, data = times,
                  auto.key = list(space = "right", text = c("McSplit\u2193",
                                                            "VBS", "Llama")),
                  xlab = "Runtime (ms)", ylim = c(0.9, 1), main = type_label)
  update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8,
                                                            name = "Dark2")))
  dev.off()
}

# Line graphs

construct_line_graph <- function(data, y_variable, variable_label,
                                 legend_position) {
  plot(range(data$labelling), range(data[, y_variable]), xlab = "Labelling (%)",
       ylab = variable_label, type = "n", main = type_label)
  for (i in 1:length(algorithms)) {
    individual_results <- subset(data, data$algorithm == algorithms[i])
    lines(individual_results$labelling, individual_results[, y_variable],
          col = colours[i])
  }
  legend(legend_position, algorithm_labels, fill = colours)
}

if (type != "unlabelled") {
  solved <- expand.grid(algorithm = algorithms, labelling = p_values)
  solved$proportion <- apply(solved, 1, function(row)
    sum(data[["data"]]$labelling == as.numeric(row[2])))
  solved$proportion <- apply(solved, 1, function(row)
    sum(data[["data"]]$labelling == as.numeric(row[2]) &
          data[["data"]][paste0(row[1], "_success")] == TRUE) /
      as.numeric(row[3]))
  png(paste0("dissertation/images/", type, "_linechart.png"), width = 480,
      height = 320)
  construct_line_graph(solved, "proportion", "Proportion solved", "bottomright")
  dev.off()

  cumulative <- expand.grid(algorithm = algorithms, labelling = p_values)
  cumulative$time <- apply(cumulative, 1, function(row)
    sum(data$data[data$data$labelling == as.numeric(row[2]), row[1]]))
  png(paste0("dissertation/images/", type, "_linechart2.png"), width = 480,
      height = 320)
  construct_line_graph(cumulative, "time", "Total runtime (ms)", "topright")
  dev.off()

  mins <- data$data[, c("labelling", algorithms)]
  mins$min <- apply(mins[,algorithms], 1, min)
  won <- expand.grid(algorithm = algorithms, labelling = p_values)
  won$count <- apply(won, 1, function(row)
    sum(mins$labelling == as.numeric(row[2]) & mins[row[1]] == mins$min))
  png(paste0("dissertation/images/", type, "_linechart3.png"), width = 480,
      height = 320)
  construct_line_graph(won, "count", "Times won", "bottomright")
  dev.off()
}