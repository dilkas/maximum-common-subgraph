library(lattice)
library(latticeExtra)

mcsplit <- read.csv("results/mcsplit.sip.csv", header = FALSE)
kdown <- read.csv("results/kdown.sip.csv", header = FALSE)
mcsplitdown <- read.csv("results/mcsplit.down.sip.csv", header = FALSE)
clique <- read.csv("results/clique.sip.csv", header = FALSE)
column_names <- c("instance", "nodes", "time", "size")
colnames(mcsplit) <- column_names
colnames(kdown) <- column_names
colnames(mcsplitdown) <- column_names
colnames(clique) <- column_names

sip_features <- read.csv("results/sip_features_individual.csv", header = FALSE)
mcs_features <- read.csv("results/mcs_features_individual.csv", header = FALSE)
feature_names <- c("graph", "vertices", "edges", "loops", "meandeg", "maxdeg",
                   "stddeg", "density", "isconnected", "meandistance",
                   "maxdistance", "proportiondistancege2",
                   "proportiondistancege3", "proportiondistancege4")
colnames(sip_features) <- feature_names
colnames(mcs_features) <- feature_names

# Filter out unsolved instances
solved <- mcsplit$instance[mcsplit$time < 1e6]
solved <- union(solved, mcsplitdown$instance[mcsplitdown$time < 1e6])
solved <- union(solved, kdown$instance[kdown$time < 1e6])
solved <- union(solved, clique$instance[clique$time < 1e6])
solved <- unique(unlist(strsplit(solved, " ")))

# In case we are interested in plotting a subset of data
sip_features <- subset(sip_features, sip_features$graph %in% solved)

# Which database are we plotting?
features <- sip_features

# Distributions of features
table(features$isconnected)
plot(density(features$vertices), main = "Number of vertices")
plot(density(features$edges), main = "Number of edges")
plot(density(features$meandeg), main = "Mean degree")
plot(density(features$maxdeg), main = "Max degree")
plot(density(features$stddeg), main = "Standard deviation of degrees")
plot(density(features$density), main = "Density")
plot(density(features$meandistance), main = "Mean distance")
plot(density(features$maxdistance), main = "Max distance")
plot(density(features$loops), main = "Number of loops")
plot(density(features$proportiondistancege2), main = "distance \u2265 2")
plot(density(features$proportiondistancege3), main = "distance \u2265 3")
plot(density(features$proportiondistancege4), main = "distance \u2265 4")

# Update features with ratio features
source("common.R")
features <- get_features(labelled = FALSE)

# Distributions of ratio features
plot(density(log(features$vertices.ratio)),
     main = "Log of ratio of the number of vertices")
plot(density(log(features$edges.ratio)),
     main = "Log of ratio of the number of edges")
plot(density(log(features$meandeg.ratio)), main = "Log of ratio of mean degree")
plot(density(log(features$maxdeg.ratio)), main = "Log of ratio of max degree")
plot(density(log(features$density.ratio)), main = "Log of ratio of density")
plot(density(log(features$meandistance.ratio)),
     main = "Log of ratio of mean distance")
plot(density(log(features$maxdistance.ratio)),
     main = "Log of ratio of max distance")
