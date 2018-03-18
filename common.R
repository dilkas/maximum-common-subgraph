# p_values only apply to labelled instances
# filtered_instances is optional
get_features <- function(p_values, filtered_instances, labelled = TRUE) {
  feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg",
                     "stddeg", "density", "isconnected", "meandistance",
                     "maxdistance", "proportiondistancege2",
                     "proportiondistancege3", "proportiondistancege4")
  original_features <- read.csv("results/mcs_features.csv", header = FALSE)

  if (!labelled)
    original_features <- rbind(original_features,
                               read.csv("results/sip_features.csv",
                                        header = FALSE))

  colnames(original_features) <- c("ID",
                                   paste("pattern", feature_names, sep = "."),
                                   paste("target", feature_names, sep = "."))

  if (!missing(filtered_instances)) {
    original_features <- subset(original_features,
                                gsub("^\\d\\d", "", original_features$ID)
                                %in% filtered_instances)
  }

  for (feature in c("vertices", "edges", "meandeg", "maxdeg", "density",
                    "meandistance", "maxdistance")) {
    original_features[paste(feature, "ratio", sep = ".")] <- (
      original_features[paste("pattern", feature, sep = ".")] /
        original_features[paste("target", feature, sep = ".")])
  }

  if (!labelled)
    return(original_features)

  features <- original_features[rep(seq_len(nrow(original_features)),
                                    each = length(p_values)), ]
  features$labelling <- p_values
  features$ID <- sprintf("%02d %s", features$labelling, features$ID)
  features[order(features$ID), ]
}

generate_feature_names <- function(labelled) {
  graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
                           "max degree", "SD of degrees", "density", "connected",
                           "mean distance", "max distance", "distance \u2265 2",
                           "distance \u2265 3", "distance \u2265 4")
  selected_features <- c("vertices", "edges", "mean degree", "max degree",
                         "density", "mean distance", "max distance")
  full_feature_names <- c(paste("pattern", graph_feature_names),
                          paste("target", graph_feature_names),
                          paste(selected_features, "ratio"))
  if (labelled)
    full_feature_names <- c(full_feature_names, "labelling")
  full_feature_names
}

# Both arguments are optional
get_costs <- function(filtered_instances, p_values) {
  costs <- read.csv("results/costs.csv", header = FALSE)
  colnames(costs) <- c("ID", "group1")

  if (!missing(filtered_instances))
    costs <- subset(costs, costs$ID %in% filtered_instances)

  if (!missing(p_values)) {
    costs <- costs[rep(seq_len(nrow(costs)), each = length(p_values)), ]
    costs$labelling <- p_values
    costs$ID <- sprintf("%02d %s", costs$labelling, costs$ID)
    costs <- costs[, c("ID", "group1")]
  }
  costs
}
