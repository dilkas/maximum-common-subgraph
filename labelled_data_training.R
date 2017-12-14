library(parallelMap)
library(llama)
parallelStartSocket(64)
parallelLibrary("llama")

labelling <- "both" # "vertex" or "both"
p_values <- c(50)

algorithms <- c("clique", "mcsplit", "mcsplitdown")
if (labelling == "vertex") {
  algorithms <- c(algorithms, "kdown")
}

filtered_instances <- readLines("results/filtered_instances")

costs <- read.csv("results/costs.csv", header = FALSE)
colnames(costs) <- c("ID", "group1")
costs <- subset(costs, costs$ID %in% filtered_instances)
costs <- costs[rep(seq_len(nrow(costs)), each = length(p_values)),]
costs$labelling <- p_values
costs$ID <- sprintf("%02d %s", costs$labelling, costs$ID)
costs <- costs[, c("ID", "group1")]

# Construct the feature data frame
feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg",
                   "density", "isconnected", "meandistance", "maxdistance",
                   "proportiondistancege2", "proportiondistancege3",
                   "proportiondistancege4")
original_features <- read.csv("results/mcs_features.csv", header = FALSE)
colnames(original_features) <- c("ID",
                                 paste("pattern", feature_names, sep = "."),
                                 paste("target", feature_names, sep = "."))
rm("feature_names")
original_features <- subset(original_features,
                            original_features$ID %in% filtered_instances)
for (feature in c("vertices", "edges", "meandeg", "maxdeg", "density",
                  "meandistance", "maxdistance")) {
  original_features[paste(feature, "ratio", sep = ".")] <- (
    original_features[paste("pattern", feature, sep = ".")] /
      original_features[paste("target", feature, sep = ".")])
}
rm("feature")
features <- original_features[rep(seq_len(nrow(original_features)),
                                  each = length(p_values)),]
rm("original_features")
features$labelling <- p_values
features$ID <- sprintf("%02d %s", features$labelling, features$ID)

#Construct the performance (running time) data frame
names <- c("ID", "nodes", "time", "size")
classes <- c("character", "NULL", "integer", "integer")
performance <- data.frame(ID = sort(features$ID))
answers <- data.frame(ID = sort(features$ID))
for (algorithm in algorithms) {
  print(paste("Loading", algorithm))
  algorithm_runtimes <- data.frame()
  for (p in p_values) {
    data_file <- read.csv(paste0("results/", algorithm, ".", labelling,
                                 ".labels.", p, ".csv"), header = FALSE,
                          colClasses = classes, col.names = names)
    data_file <- subset(data_file, data_file$ID %in% filtered_instances)
    data_file$ID <- sprintf("%02d %s", p, data_file$ID)
    algorithm_runtimes <- rbind(algorithm_runtimes,
                                data_file[order(data_file$ID),])
  }
  algorithm_runtimes$time <- pmin(algorithm_runtimes$time, 1000000)
  performance[, algorithm] <- algorithm_runtimes$time
  answers[, algorithm] <- algorithm_runtimes$size
}
rm("algorithm", "algorithm_runtimes", "classes", "data_file",
   "filtered_instances", "names", "p")
performance$mins <- as.numeric(apply(performance, 1, min))
performance <- performance[performance$mins < 1000000,
                           names(performance) != "mins"]
features <- features[features$ID %in% performance$ID,]
costs <- costs[costs$ID %in% features$ID,]

success <- cbind(performance)
success[, -1] <- success[, -1] < 1000000
answers <- answers[answers$ID %in% performance$ID,]
answers$all_finished <- apply(success[, -1], 1, all)
answers <- answers[answers$all_finished,]
all(answers$mcsplit == answers$mcsplitdown)
all(answers$mcsplit == answers$kdown)
all(answers$clique == answers$mcsplit)

data <- input(features, performance, success,
              list(groups = list(group1 = colnames(features)[-1]),
                   values = costs))
rm("features", "performance", "success", "costs")
saveRDS(data, sprintf("models/%s_labels_data.rds", labelling))
model <- classify(makeLearner("classif.randomForest"),
                  cvFolds(data, stratify = TRUE))
saveRDS(model, sprintf("models/%s_labels.rds", labelling))
parallelStop()

# Plots
times <- subset(data$data, T, data$performance)
times$vbs <- apply(times, 1, min)
times$llama <- times[model[["predictions"]][["algorithm"]]]
cols <- gray(seq(1, 0, length.out = 255))
labels <- c("clique", sprintf('k\u2193'), "McSplit", sprintf('McSplit\u2193'),
            "VBS", "Llama")
labels <- c("clique", sprintf('k\u2193'), "McSplit", sprintf('McSplit\u2193'),
            "VBS")

# Log runtimes by solver and instance
#image(log10(t(as.matrix(times))), axes = F, col = cols)
#axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance) - 1)), las = 2)

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
times = performance
length(which(times$clique < times$kdown & times$clique < times$mcsplit &
               times$clique < times$mcsplitdown))
length(which(times$kdown < times$clique & times$kdown < times$mcsplit &
               times$kdown < times$mcsplitdown))
length(which(times$mcsplit < times$clique & times$mcsplit < times$kdown &
               times$mcsplit < times$mcsplitdown))
length(which(times$mcsplitdown < times$clique &
               times$mcsplitdown < times$kdown &
               times$mcsplitdown < times$mcsplit))

summary(times[!(times$clique < times$kdown & times$clique < times$mcsplit &
                  times$clique < times$mcsplitdown) &
                !(times$kdown < times$clique & times$kdown < times$mcsplit &
                    times$kdown < times$mcsplitdown) &
                !(times$mcsplit < times$clique & times$mcsplit < times$kdown &
                    times$mcsplit < times$mcsplitdown) &
                !(times$mcsplitdown < times$clique &
                    times$mcsplitdown < times$kdown &
                    times$mcsplitdown < times$mcsplit), ])

library(lattice)
library(latticeExtra)
ecdfplot(~ clique + kdown + mcsplit + mcsplitdown + vbs + llama, data = times,
         auto.key = list(space = "right",text = labels), xlab = "Runtime (ms)")
ecdfplot(~ clique + kdown + mcsplit + mcsplitdown + vbs, data = times,
         auto.key = list(space = "right", text = labels), xlab = "Runtime (ms)")

# Heatmaps for pattern/target features. Group differently?
features <- subset(data$data, T, data$features)
nFeatures <- normalize(features)
graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
                         "max degree", "SD of degrees", "density", "connected",
                         "mean distance", "max distance", "distance \u2265 2",
                         "distance \u2265 3", "distance \u2265 4")
full_feature_names <- c(paste("pattern", graph_feature_names),
                        paste("target", graph_feature_names))
par(mar = c(1, 10, 1, 1))
image(as.matrix(nFeatures$features), axes = F, col = cols)
axis(2, labels = full_feature_names,
     at = seq(0, 1, 1/(length(data$features) - 1)), las = 2)
