# Investigating how the labels are distributed
lines <- readLines("results/labels.csv")
counts <- lapply(lines, function(l) as.integer(strsplit(l, ",")[[1]]))
expectations <- unlist(lapply(counts, function(c) rep(sum(c)/length(c), length(c))))
probabilities <- unlist(lapply(counts, function(c) rep(1/length(c), length(c))))
counts <- unlist(counts)
differences <- expectations - counts
hist(differences, main = paste("Histogram of", expression(E(C) - C)), xlab = expression(E(C) - C))
