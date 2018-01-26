#instances <- readLines("results/mcs_instances")
#sample <- sample(instances, 30000)
#writeLines(sample, "results/filtered_instances")

instances <- readLines("results/filtered_instances_one_filename")
sample <- sample(instances, 10000)
writeLines(sample, "results/filtered_instances2")
