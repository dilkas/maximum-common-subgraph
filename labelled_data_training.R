library(parallelMap)
library(llama)
parallelStartSocket(64)
parallelLibrary("llama")

labelling <- "both" # "vertex" or "both"
type <- "both_labels"
p_values <- c(5, 10, 15, 20, 25, 33, 50)
filtered_instances <- readLines("results/filtered_instances")
algorithms <- c("clique", "mcsplit", "mcsplitdown")

costs <- read.csv("results/costs.csv", header = FALSE)
colnames(costs) <- c("ID", "group1")
costs <- subset(costs, costs$ID %in% filtered_instances)
costs <- costs[rep(seq_len(nrow(costs)), each = length(p_values)), ]
costs$labelling <- p_values
costs$ID <- sprintf("%02d %s", costs$labelling, costs$ID)
costs <- costs[, c("ID", "group1")]

# Construct the feature data frame
source("common.R")
features <- get_features(p_values, filtered_instances)

#Construct the performance (running time) data frame
names <- c("ID", "nodes", "time", "size")
classes <- c("character", "NULL", "integer", "integer")
performance <- data.frame(ID = features$ID)
answers <- data.frame(ID = features$ID)
for (algorithm in algorithms) {
  print(paste("Loading", algorithm))
  algorithm_runtimes <- data.frame()
  for (p in p_values) {
    data_file <- read.csv(paste0("results/", algorithm, ".", labelling,
                                 ".labels.", p, ".csv"), header = FALSE,
                          colClasses = classes, col.names = names)
    data_file <- subset(data_file,
                        sub("^\\d\\d", "", data_file$ID) %in% filtered_instances)
    data_file$ID <- sprintf("%02d %s", p, data_file$ID)
    algorithm_runtimes <- rbind(algorithm_runtimes,
                                data_file[order(data_file$ID), ])
  }
  algorithm_runtimes$time <- pmin(algorithm_runtimes$time, 1e6)
  performance[, algorithm] <- algorithm_runtimes$time
  answers[, algorithm] <- algorithm_runtimes$size
}
rm("algorithm", "algorithm_runtimes", "classes", "data_file",
   "filtered_instances", "names", "p")

# "Warning message: NAs introduced by coercion" is normal and is fixed on the
# next line
performance$mins <- as.numeric(apply(performance, 1, min))
performance$mins[is.na(performance$mins)] <- 1e6

# Sanity check: all should be empty
#performance[performance$clique < performance$mins, ]
#performance[performance$mcsplit < performance$mins, ]
#performance[performance$mcsplitdown < performance$mins, ]

performance <- performance[performance$mins < 1e6,
                           names(performance) != "mins"]
features <- features[features$ID %in% performance$ID, ]
costs <- costs[costs$ID %in% performance$ID, ]

success <- cbind(performance)
success[, -1] <- success[, -1] < 1e6
answers <- answers[answers$ID %in% performance$ID, ]
answers$all_finished <- apply(success[, -1], 1, all)
answers <- answers[answers$all_finished, ]

# All should be true
all(answers$mcsplit == answers$mcsplitdown)
all(answers$mcsplit == answers$kdown)
all(answers$clique == answers$mcsplit)
all(answers$clique == answers$fusion1)
all(answers$clique == answers$fusion2)

data <- input(features, performance, success,
              list(groups = list(group1 = colnames(features)[-1]),
                   values = costs))
#rm("features", "performance", "success", "costs")
#saveRDS(data, sprintf("models/%s_labels_data.rds", labelling))
model <- classify(makeLearner("classif.randomForest"),
                  cvFolds(data, stratify = TRUE))
saveRDS(model, sprintf("models/%s_labels.rds", labelling))
parallelStop()

# ECDF plot for fusion

library(lattice)
library(latticeExtra)
library(RColorBrewer)

png("text/dissertation/images/fusion_ecdf.png", width = 480, height = 320)
plt <- ecdfplot(~ clique + mcsplit + mcsplitdown + fusion1 + fusion2,
                data = performance,
#                data = performance[startsWith(as.character(performance$ID),
#                                              "50"), ],
               auto.key = list(space = "right",
                               text = c("clique", "McSplit", "McSplit\u2193",
                                        "Fusion 1", "Fusion 2")),
               xlab = "Runtime (ms)", ylim = c(0.8, 1), xlim = c(0, 999999))
update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8,
                                                          name = "Dark2")))
dev.off()

# Cumulative runtime dependence on the labelling percentage
colours <- rainbow(length(algorithms))
cumulative <- expand.grid(algorithm = algorithms, labelling = p_values)
cumulative$time <- apply(cumulative, 1, function(row)
  sum(performance[startsWith(as.character(performance$ID),
                             sprintf("%02d", as.numeric(row[2]))), row[1]]))
png(paste0("text/dissertation/images/fusion_linechart.png"), width = 480,
    height = 320)
plot(range(cumulative$labelling), range(cumulative$time),
     xlab = "Labelling (%)", ylab = "Total runtime (ms)", type = "n",
     main = "Both labels")
for (i in 1:length(algorithms)) {
  individual_results <- subset(cumulative,
                               cumulative$algorithm == algorithms[i])
  lines(individual_results$labelling, individual_results$time,
        col = colours[i])
}
legend("topright", c("clique", "McSplit", "McSplit\u2193", "Fusion 1",
                     "Fusion 2"), fill = colours)
dev.off()
