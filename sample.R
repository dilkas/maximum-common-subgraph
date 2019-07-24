instances <- readLines("results/filtered_instances")
sample <- sample(instances, 1000)
writeLines(sample, "results/filtered_instances3")
