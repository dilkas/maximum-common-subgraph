sip <- read.csv("results/sip_features.csv", header = FALSE)
mcs <- read.csv("results/mcs_features.csv", header = FALSE)
feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")
colnames(sip) <- c("ID", paste("pattern", feature_names, sep = "."), paste("target", feature_names, sep = "."))
colnames(mcs) <- c("ID", paste("pattern", feature_names, sep = "."), paste("target", feature_names, sep = "."))

# Investigating how the labels are distributed
lines <- readLines("results/labels.csv")
counts <- lapply(lines, function(l) as.integer(strsplit(l, ",")[[1]]))
expectations <- unlist(lapply(counts, function(c) rep(sum(c)/length(c), length(c))))
probabilities <- unlist(lapply(counts, function(c) rep(1/length(c), length(c))))
counts <- unlist(counts)

chisq.test(counts, counts)
chisq.test(10 * expectations, p = probabilities, rescale.p = TRUE)
differences <- expectations - counts
hist(differences, main = paste("Histogram of", expression(E(C) - C)), xlab = expression(E(C) - C))
