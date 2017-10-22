require(llama)

names <- c("ID", "nodes", "time", "size")
clique <- read.csv("results/clique.csv", header = FALSE)
kdown <- read.csv("results/kdown.sip.csv", header = FALSE)
mcsplit <- read.csv("results/mcsplit.sip.csv", header = FALSE)
colnames(clique) <- names
colnames(kdown) <- names
colnames(mcsplit) <- names

feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")
features <- read.csv("results/features.csv.temp", header = FALSE)
colnames(features) <- c("ID", paste("pattern", feature_names), paste("target", feature_names))

performance <- data.frame(ID = features[1])
performance <- merge(performance, clique[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique")
performance <- merge(performance, kdown[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown")
performance <- merge(performance, mcsplit[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown", "mcsplit")

success <- data.frame(ID = features[1])
success$clique <- clique$time[clique$ID==success$ID]

#data = input(read.csv("features.csv"), read.csv("times.csv"))
data(satsolvers)
data = satsolvers

folds = cvFolds(data)
model = classify(makeLearner("classif.randomForest"), folds)

mean(misclassificationPenalties(data, vbs))
mean(misclassificationPenalties(folds, model))
mean(misclassificationPenalties(data, singleBest))
