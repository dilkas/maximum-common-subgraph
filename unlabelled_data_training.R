library(parallelMap)
library(llama)
parallelStartSocket(64)
parallelLibrary("llama")

# Read the data
names <- c("ID", "nodes", "time", "size")
classes <- c("character", "numeric", "numeric", "numeric")

read_data <- function(algorithm) {
  sip <- read.csv(paste0("results/", algorithm, ".sip.csv"), header = FALSE,
                  colClasses = classes, col.names = names)
  mcs <- read.csv(paste0("results/", algorithm, ".mcs.csv"), header = FALSE,
                  colClasses = classes, col.names = names)
  rbind(sip, mcs)
}

clique <- read_data("clique")
kdown <- read_data("kdown")
mcsplit <- read_data("mcsplit")
mcsplitdown <- read_data("mcsplitdown")

# Construct the feature data frame
source("common.R")
features <- get_features(labelled = FALSE)

# Check the clique dataset
clique_features <- merge(clique, features, by = "ID")
# Are there any instances that are too big to be solved?
clique_features$ID[clique_features$pattern.vertices *
                     clique_features$target.vertices >= 16000]
# What instances are missing?
small_features <- subset(features, pattern.vertices * target.vertices < 16000)
small_features$ID[!(small_features$ID %in% clique$ID)]

# Check if the answers match
answers <- data.frame(ID = features[1])
answers <- merge(answers, kdown[kdown$time < 1e6, c("ID", "size")], by = "ID",
                 all.x = TRUE)
colnames(answers) <- c("ID", "kdown")
answers <- merge(answers, mcsplit[mcsplit$time < 1e6, c("ID", "size")],
                 by = "ID", all.x = TRUE)
colnames(answers) <- c("ID", "kdown", "mcsplit")
answers <- merge(answers, clique[clique$time < 1e6, c("ID", "size")],
                 by = "ID", all.x = TRUE)
colnames(answers) <- c("ID", "kdown", "mcsplit", "clique")
answers$equal <-  answers$mcsplit == answers$clique
all(answers[complete.cases(answers), "equal"])

#Construct the performance (running time) data frame
performance <- data.frame(ID = features[1])
performance <- merge(performance, clique[, c("ID", "time")], by = "ID",
                     all.x = TRUE)
colnames(performance) <- c("ID", "clique")
performance <- merge(performance, kdown[, c("ID", "time")], by = "ID",
                     all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown")
performance <- merge(performance, mcsplit[, c("ID", "time")], by = "ID",
                     all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown", "mcsplit")
performance <- merge(performance, mcsplitdown[, c("ID", "time")], by = "ID",
                     all.x = TRUE)
rm("clique", "kdown", "mcsplit", "mcsplitdown")
colnames(performance) <- c("ID", "clique", "kdown", "mcsplit", "mcsplitdown")
performance$clique[is.na(performance$clique)] <- 1e6
performance$clique <- pmin(performance$clique, 1e6)
performance$kdown <- pmin(performance$kdown, 1e6)
performance$mcsplit <- pmin(performance$mcsplit, 1e6)
performance$mcsplitdown <- pmin(performance$mcsplitdown, 1e6)
performance <- performance[performance$clique < 1e6 |
                             performance$kdown < 1e6 |
                             performance$mcsplit < 1e6 |
                             performance$mcsplitdown < 1e6, ]
performance <- performance[order(performance$ID), ]
features <- features[features$ID %in% performance$ID, ]

# Construct the success data frame
success <- cbind(performance)
success$clique <- success$clique < 1e6
success$kdown <- success$kdown < 1e6
success$mcsplit <- success$mcsplit < 1e6
success$mcsplitdown <- success$mcsplitdown < 1e6

costs <- read.csv("results/costs.csv", header = FALSE)
colnames(costs) <- c("ID", "group1")

data <- input(features, performance, success, list(
  groups = list(group1 = colnames(features)[-1]), values = costs))
rm("features", "performance", "success")
saveRDS(data, "models/unlabelled_data.rds")
model <- classify(makeLearner("classif.randomForest"),
                  cvFolds(data, stratify = TRUE))
saveRDS(model, "models/unlabelled.rds")
parallelStop()

# Plots
times <- subset(data$data, T, data$performance)
times$vbs <- apply(times, 1, min)
cols <- gray(seq(1, 0, length.out = 255))
labels <- c("clique", sprintf("k\u2193"), "McSplit",
            sprintf("McSplit\u2193"), "VBS")

# Log runtimes by solver and instance
image(log10(t(as.matrix(times[, -5]))), axes = F, col = cols)
axis(1, labels = labels[-5], at = seq(0, 1, 1 / (length(data$performance) - 1)),
     las = 2)

# White - first, black - last (weird results because of equal timing out values)
image(apply(times[, -5], 1, order), axes = F, col = cols)
axis(1, labels = labels[-5], at = seq(0, 1, 1 / (length(data$performance) - 1)),
     las = 2)

# Tables for best algorithms
times <- performance[grep("data/sip-instances/images-CVIU11", performance$ID), ]
times <- performance[grep("data/sip-instances/images-PR15", performance$ID), ]
times <- performance[grep("data/sip-instances/largerGraphs", performance$ID), ]
times <- performance[grep("data/sip-instances/LV", performance$ID), ]
times <- performance[grep("data/sip-instances/meshes-CVIU11", performance$ID), ]
times <- performance[grep("data/sip-instances/phase", performance$ID), ]
times <- performance[grep("data/sip-instances/scalefree", performance$ID), ]
times <- performance[grep("data/sip-instances/si", performance$ID), ]
times <- performance[grep("data/mcs-instances", performance$ID), ]
times$vbs <- apply(times, 1, min)

# How many times is each algorithm the best?
length(which(times$clique <= times$kdown & times$clique <= times$mcsplit &
               times$clique <= times$mcsplitdown))
length(which(times$kdown <= times$clique & times$kdown <= times$mcsplit &
               times$kdown <= times$mcsplitdown))
length(which(times$mcsplit <= times$clique & times$mcsplit <= times$kdown &
               times$mcsplit <= times$mcsplitdown))
length(which(times$mcsplitdown <= times$clique &
               times$mcsplitdown <= times$kdown &
               times$mcsplitdown <= times$mcsplit))

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
ecdfplot(~ clique + kdown + mcsplit + mcsplitdown + vbs, data = times,
         auto.key = list(space = "right", text = labels), xlab = "Runtime (ms)")

# Heatmaps for pattern/target features
features <- subset(data$data, T, data$features)
n_features <- normalize(features)
graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
                         "max degree", "SD of degrees", "density", "connected",
                         "mean distance", "max distance", "distance \u2265 2",
                         "distance \u2265 3", "distance \u2265 4")
full_feature_names <- c(paste("pattern", graph_feature_names),
                        paste("target", graph_feature_names),
                        c("vertices ratio", "edges ratio", "mean degree ratio",
                          "max degree ratio", "density ratio",
                          "mean distance ratio", "max distance ratio"))
par(mar = c(1, 10, 1, 1))
image(as.matrix(n_features$features), axes = F, col = cols)
axis(2, labels = full_feature_names,
     at = seq(0, 1, 1 / (length(data$features) - 1)), las = 2)