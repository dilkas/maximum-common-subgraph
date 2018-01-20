library(corrgram)

p.values <- c(5, 10, 15, 20, 25, 33, 50)
runtime.names <- c("ID", "nodes", "time", "size")
runtime.classes <- c("character", "NULL", "integer", "NULL")
feature.names <- c("ID", "vertices", "edges", "meandeg", "maxdeg", "stddeg",
                   "density")
nice.feature.names <- c("ID", "Vertices", "Edges", "Mean degree", "Max degree",
                        "Standard deviation of degrees", "Density")

ReadFiles <- function(feature.filename, runtime.filename) {
  features <- read.csv(feature.filename, header = FALSE,
                       col.names = feature.names)
  runtimes <- read.csv(runtime.filename, header = FALSE,
                       colClasses = runtime.classes, col.names = runtime.names)
  features <- merge(features, runtimes)
  features$time <- pmin(features$time, 1e6)
  return(features)
}

# Read in the data
data <- ReadFiles("results/association.mcs.csv", "results/clique.mcs.csv")
for (p in p.values) {
  for (labelling in c("vertex", "both")) {
    local.data <- ReadFiles(paste("results/association", labelling, "labels",
                                  p, "csv", sep = "."),
                            paste("results/clique",labelling, "labels", p,
                                  "csv", sep = "."))
    local.data$ID <- sprintf("%s %02d %s", labelling, p, local.data$ID)
    data <- rbind(data, local.data)
  }
}
data$time[is.na(data$time)] <- 1e6
rm("local.data")
#data <- subset(data, time < 1e6)

# Density plots
for (i in 2:length(feature.names)) {
  png(paste0("text/dissertation/images/", feature.names[i], "_density.png"),
      width = 480, height = 320)
  plot(density(data[, feature.names[i]]), main = nice.feature.names[i])
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
corrgram(data[, -1], labels = c(nice.feature.names[2:5], "SD of degrees",
                                "Density", "Time"), lower.panel = NULL,
         panel = panel.cor, cor.method = "spearman", cex = 1.2)
dev.off()
