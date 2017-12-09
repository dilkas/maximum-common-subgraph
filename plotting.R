library(lattice)
library(latticeExtra)

mcsplit <- read.csv("results/mcsplit.sip.csv", header = FALSE)
kdown <- read.csv("results/kdown.sip.csv", header = FALSE)
mcsplitdown <- read.csv("results/mcsplit.down.sip.csv", header = FALSE)
clique <- read.csv("results/clique.sip.csv", header = FALSE)
colnames(mcsplit) <- c("instance", "nodes", "time", "size")
colnames(kdown) <- c("instance", "nodes", "time", "size")
colnames(mcsplitdown) <- c("instance", "nodes", "time", "size")
colnames(clique) <- c("instance", "nodes", "time", "size")

sip_features <- read.csv("results/sip_features_individual.csv", header = FALSE)
mcs_features <- read.csv("results/mcs_features_individual.csv", header = FALSE)
colnames(sip_features) <- c("graph", "vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")
colnames(mcs_features) <- c("graph", "vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")

# Plot ECDFs
#runtimes = data.frame(mcsplit = mcsplit$time, mcsplitdown = mcsplitdown$time, kdown = kdown$time)
#ecdfplot(~ mcsplit + mcsplitdown + kdown, data = runtimes, auto.key = list(space = "right"), main = "Unlabelled, undirected, not connected ")

# Filter out unsolved instances
solved <- mcsplit$instance[mcsplit$time < 1000000]
solved <- union(solved, mcsplitdown$instance[mcsplitdown$time < 1000000])
solved <- union(solved, kdown$instance[kdown$time < 1000000])
solved <- union(solved, clique$instance[clique$time < 1000000])
solved <- unique(unlist(strsplit(solved, " ")))
sip_features <- subset(sip_features, sip_features$graph %in% solved)

features <- sip_features
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
plot(density(features$proportiondistancege2), main = "distance \u2265 2")
plot(density(features$proportiondistancege3), main = "distance \u2265 3")
plot(density(features$proportiondistancege4), main = "distance \u2265 4")
plot(density(log(features$vertices.ratio)), main = "Log of ratio of the number of vertices")
plot(density(log(features$edges.ratio)), main = "Log of ratio of the number of edges")
plot(density(log(features$meandeg.ratio)), main = "Log of ratio of mean degree")
plot(density(log(features$maxdeg.ratio)), main = "Log of ratio of max degree")
plot(density(log(features$density.ratio)), main = "Log of ratio of density")
plot(density(log(features$meandistance.ratio)), main = "Log of ratio of mean distance")
plot(density(log(features$maxdistance.ratio)), main = "Log of ratio of max distance")

