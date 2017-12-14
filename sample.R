instances <- readLines("results/mcs_instances")
sample <- sample(instances, 30000)
writeLines(sample, "results/filtered_instances")
