library(lattice)
library(latticeExtra)

mcsplit <- read.csv("results/mcsplit.sip.csv", header = FALSE)
kdown <- read.csv("results/kdown.sip.csv", header = FALSE)
mcsplitdown <- read.csv("results/mcsplit.down.sip.csv", header = FALSE)
colnames(mcsplit) <- c("instance", "nodes", "time", "size")
colnames(kdown) <- c("instance", "nodes", "time", "size")
colnames(mcsplitdown) <- c("instance", "nodes", "time", "size")

sip_features <- read.csv("results/sip_features_individual.csv", header = FALSE)
colnames(sip_features) <- c("graph", "vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")

sip <- read.csv("results/sip_features.csv", header = FALSE)
mcs <- read.csv("results/mcs_features.csv", header = FALSE)
feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")
colnames(sip) <- c("ID", paste("pattern", feature_names, sep = "."), paste("target", feature_names, sep = "."))
colnames(mcs) <- c("ID", paste("pattern", feature_names, sep = "."), paste("target", feature_names, sep = "."))

# Plot ECDFs
runtimes = data.frame(mcsplit = mcsplit$time, mcsplitdown = mcsplitdown$time, kdown = kdown$time)
ecdfplot(~ mcsplit + mcsplitdown + kdown, data = runtimes, auto.key = list(space = "right"), main = "Unlabelled, undirected, not connected ")

# Filter out unsolved instances
solved <- mcsplit$instance[mcsplit$time < 1000000]
solved <- union(solved, mcsplitdown$instance[mcsplitdown$time < 1000000])
solved <- union(solved, kdown$instance[kdown$time < 1000000])
solved <- unique(unlist(strsplit(solved, " ")))
features <- subset(sip_features, graph %in% solved)

# Distributions of features
#table(features$isconnected)
plot(density(features$vertices), main = "Number of vertices")
plot(density(features$edges), main = "Number of edges")
plot(density(features$meandeg), main = "Mean degree")
plot(density(features$maxdeg), main = "Max degree")
plot(density(features$stddeg), main = "Standard deviation of degrees")
plot(density(features$density), main = "Density")
plot(density(features$meandistance), main = "Mean distance")
plot(density(features$maxdistance), main = "Max distance")
plot(density(features$loops), main = "Number of loops")
plot(density(features$proportiondistancege2), main = "Proportion of vertex pairs with distance at least 2")
plot(density(features$proportiondistancege3), main = "Proportion of vertex pairs with distance at least 3")
plot(density(features$proportiondistancege4), main = "Proportion of vertex pairs with distance at least 4")
