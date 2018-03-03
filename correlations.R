library(corrgram)

p_values <- c(5, 10, 15, 20, 25, 33, 50)
runtime_names <- c("ID", "nodes", "time", "size")
runtime_classes <- c("character", "NULL", "integer", "NULL")
feature_names <- c("ID", "vertices", "edges", "meandeg", "maxdeg", "stddeg",
                   "density")
nice_feature_names <- c("ID", "Vertices", "Edges", "Mean degree", "Max degree",
                        "Standard deviation of degrees", "Density")

read_files <- function(feature_filename, runtime_filename) {
  features <- read.csv(feature_filename, header = FALSE,
                       col.names = feature_names)
  runtimes <- read.csv(runtime_filename, header = FALSE,
                       colClasses = runtime_classes, col.names = runtime_names)
  features <- merge(features, runtimes)
  features$time <- pmin(features$time, 1e6)
  return(features)
}

# Read in the data
data <- read_files("results/association.mcs.csv", "results/clique.mcs.csv")
for (p in p_values) {
  for (labelling in c("vertex", "both")) {
    local_data <- read_files(paste("results/association", labelling, "labels",
                                  p, "csv", sep = "."),
                            paste("results/clique", labelling, "labels", p,
                                  "csv", sep = "."))
    local_data$ID <- sprintf("%s %02d %s", labelling, p, local_data$ID)
    data <- rbind(data, local_data)
  }
}
data$time[is.na(data$time)] <- 1e6
rm("local.data")
#data <- subset(data, time < 1e6)

# Density plots
for (i in 2:length(feature_names)) {
  png(paste0("text/dissertation/images/", feature_names[i], "_density.png"),
      width = 480, height = 320)
  plot(density(data[, feature_names[i]]), main = nice_feature_names[i])
  dev.off()
}
png("text/dissertation/images/edges_density.png", width = 480, height = 320)
plot(density(log(data$edges)), main = "Log of the number of edges")
dev.off()
png("text/dissertation/images/time_density.png", width = 480, height = 320)
plot(density(log(data$time)), main = "Log of runtime")
dev.off()

# Correlation plot
png("text/dissertation/images/correlations.png", width = 480, height = 320)
corrgram(data[, -1], labels = c(nice_feature_names[2:5], "SD of degrees",
                                "Density", "Time"), lower.panel = NULL,
         panel = panel.cor, cor.method = "spearman", cex = 1.2)
dev.off()
