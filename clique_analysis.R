# Various parameters and labels
p.values <- c(5, 10, 15, 20, 25, 33, 50)
feature.names <- c("ID", "vertices", "edges", "meandeg", "maxdeg", "stddeg",
                   "density")
nice.feature.names <- c("ID", "Number of vertices", "Number of edges",
                        "Mean degree", "Max degree",
                        "Standard deviation of degrees", "Density")
ylab.names <- c("", "Log of the number of vertices",
                "Log of the number of edges", "Log of mean degree",
                "Log of max degree",
                "Log of the standard deviation of degrees", "Log of density")
labelling.types <- c("unlabelled", "vertex_labels", "both_labels")

# Reading in the data
data <- data.frame()
for (type in labelling.types) {
  runtimes <- readRDS(paste0("models/", type, "_data.rds"))
  if (type == "unlabelled") {
    features <- read.csv("results/association.mcs.csv", header = FALSE,
                         col.names = feature.names)
  } else {
    features <- data.frame()
    for (p in p.values) {
      temp.features <- read.csv(paste("results/association",
                                      gsub("_", ".", type), p, "csv",
                                      sep = "."),
                                header = FALSE, col.names = feature.names)
      temp.features$ID <- sprintf("%02d %s", p, temp.features$ID)
      features <- rbind(features, temp.features)
    }
  }
  temp.frame <- data.frame(ID = runtimes$data$ID)
  temp.frame$best <- runtimes$best
  data <- rbind(data, merge(features, temp.frame))
}
data$clique.won <- sapply(data$best, function(v) "clique" %in% v)

# Boxplots
for (i in 2:length(feature.names)) {
  png(paste0("text/dissertation/images/", feature.names[i], "_boxplot.png"),
      width = 480, height = 320)
  boxplot(data[,feature.names[i]] ~ data$clique.won, log = "y",
          main = nice.feature.names[i], xlab = "Clique won",
          ylab = ylab.names[i])
  dev.off()
}

wilcox.test(data$vertices[data$clique.won], data$vertices[!data$clique.won])

# TODO: ...