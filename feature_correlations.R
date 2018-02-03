library(corrplot)

# Read in the features
feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg",
                   "density", "isconnected", "meandistance", "maxdistance",
                   "proportiondistancege2", "proportiondistancege3",
                   "proportiondistancege4")
features <- read.csv("results/sip_features.csv", header = FALSE)
colnames(features) <- c("ID", paste("pattern", feature_names, sep = "."),
                        paste("target", feature_names, sep = "."))
features2 <- read.csv("results/mcs_features.csv", header = FALSE)
colnames(features2) <- c("ID", paste("pattern", feature_names, sep = "."),
                         paste("target", feature_names, sep = "."))
features <- rbind(features, features2)
rm("features2", "feature_names")
for (feature in c("vertices", "edges", "meandeg", "maxdeg", "density",
                  "meandistance", "maxdistance")) {
  features[paste(feature, "ratio", sep = ".")] <- (
    features[paste("pattern",feature, sep = ".")] /
      features[paste("target", feature, sep = ".")])
}
# Construct a vector of feature names
graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
                         "max degree", "SD of degrees", "density", "connected",
                         "mean distance", "max distance", "distance \u2265 2",
                         "distance \u2265 3", "distance \u2265 4")
selected_features <- c("vertices", "edges", "mean degree", "max degree",
                       "density", "mean distance", "max distance")
full_feature_names <- c(paste("pattern", graph_feature_names),
                        paste("target", graph_feature_names),
                        paste(selected_features, "ratio"))
colnames(features) <- c("ID", full_feature_names)

# Plot correlations
M <- cor(features[, -1], method = "spearman")
png("text/dissertation/images/feature_correlations.png", width = 960, height = 640)
corrplot(M, diag = FALSE, tl.pos = "td", tl.cex = 1, method = "color", type = "upper")
dev.off()
