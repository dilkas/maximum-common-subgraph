p.values <- c(5, 10, 15, 20, 25, 33, 50)
runtime.names <- c("ID", "nodes", "time", "size")
runtime.classes <- c("character", "NULL", "integer", "NULL")
feature.names <- c("ID", "vertices", "edges", "meandeg", "maxdeg", "stddeg",
                   "density")
nice.feature.names <- c("ID", "Number of vertices", "Number of edges",
                        "Mean degree", "Max degree",
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

# TODO: plot densities
for (i in 2:length(colnames(data))) {
  png(paste0("text/dissertation/images/", feature, "_density.png"),
      width = 480, height = 320)
  plot(density(data[, feature]), main = "")
  dev.off()
}

library(corrgram)
corrgram(data)
#library(Hmisc)
cor(data[, -1])

data.no.timeouts <- subset(data, time < 1e6)
cor(data.no.timeouts[, -1])
