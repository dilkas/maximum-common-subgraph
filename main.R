require(llama)

# Import running time data and fix header names
names <- c("ID", "nodes", "time", "size")
clique <- read.csv("results/clique.csv", header = FALSE)
kdown <- read.csv("results/kdown.sip.csv", header = FALSE)
mcsplit <- read.csv("results/mcsplit.sip.csv", header = FALSE)
colnames(clique) <- names
colnames(kdown) <- names
colnames(mcsplit) <- names

# Construct the feature data frame
feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")
features <- read.csv("results/sip_features.csv", header = FALSE)
colnames(features) <- c("ID", paste("pattern", feature_names, sep = "."), paste("target", feature_names, sep = "."))

# Construct the performance (running time) data frame
performance <- data.frame(ID = features[1])
performance <- merge(performance, clique[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique")
performance <- merge(performance, kdown[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown")
performance <- merge(performance, mcsplit[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown", "mcsplit")

# Construct the success data frame
success <- data.frame(ID = features[1],
                      clique = ifelse(!is.na(performance$clique) &&
                                        performance$clique < 1000, "T", "F"),
                      kdown = ifelse(performance$kdown < 1000000, "T", "F"),
                      mcsplit = ifelse(performance$mcsplit < 1000000, "T", "F"))

data = input(features, performance, success)
folds = cvFolds(data)
model = classify(makeLearner("classif.randomForest"), folds)

mean(misclassificationPenalties(data, vbs))
mean(misclassificationPenalties(folds, model))
mean(misclassificationPenalties(data, singleBest))
