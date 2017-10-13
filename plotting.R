library(lattice)
library(latticeExtra)

mcsplit <- read.csv("results/mcsplit.si-scalefree.csv", header = FALSE)
kdown <- read.csv("results/kdown.si-scalefree.csv", header = FALSE)
colnames(mcsplit) <- c("instance", "nodes", "time", "size")
colnames(kdown) <- c("instance", "nodes", "time", "size")

runtimes = data.frame(mcsplit = mcsplit$time, kdown = kdown$time)
ecdfplot(~ mcsplit + kdown, data = runtimes, auto.key = list(space = "right"), main = "Unlabelled, undirected, not connected ")
