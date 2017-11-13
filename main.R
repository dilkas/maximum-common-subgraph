require(llama)
require(FSelector)

# Import running time data and fix header names
names <- c("ID", "nodes", "time", "size")
clique <- read.csv("results/clique.sip.csv", header = FALSE)
kdown <- read.csv("results/kdown.sip.csv", header = FALSE)
mcsplit <- read.csv("results/mcsplit.sip.csv", header = FALSE)
mcsplitdown <- read.csv("results/mcsplit.down.sip.csv", header = FALSE)
colnames(clique) <- names
colnames(kdown) <- names
colnames(mcsplit) <- names
colnames(mcsplitdown) <- names

# Construct the feature data frame
feature_names <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")
features <- read.csv("results/sip_features.csv", header = FALSE)
colnames(features) <- c("ID", paste("pattern", feature_names, sep = "."), paste("target", feature_names, sep = "."))

# Check the clique dataset
clique_features <- merge(clique, features, by = "ID")
# Are there any instances that are too big to be solved?
clique_features$ID[clique_features$pattern.vertices * clique_features$target.vertices >= 16000]
# What instances are missing?
small_features <- subset(features, features$pattern.vertices * features$target.vertices < 16000)
small_features$ID[!(small_features$ID %in% clique$ID)]

# Check if the answers match
answers <- data.frame(ID = features[1])
answers <- merge(answers, kdown[kdown$time < 1000000, c("ID", "size")], by = "ID", all.x = TRUE)
colnames(answers) <- c("ID", "kdown")
answers <- merge(answers, mcsplit[mcsplit$time < 1000000, c("ID", "size")], by = "ID", all.x = TRUE)
colnames(answers) <- c("ID", "kdown", "mcsplit")
answers <- merge(answers, clique[clique$time < 1000000, c("ID", "size")], by = "ID", all.x = TRUE)
colnames(answers) <- c("ID", "kdown", "mcsplit", "clique")
answers$equal = answers$mcsplit == answers$clique
all(answers[complete.cases(answers),"equal"])

#Construct the performance (running time) data frame
performance <- data.frame(ID = features[1])
performance <- merge(performance, clique[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique")
performance <- merge(performance, kdown[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown")
performance <- merge(performance, mcsplit[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown", "mcsplit")
performance <- merge(performance, mcsplitdown[, c("ID", "time")], by = "ID", all.x = TRUE)
colnames(performance) <- c("ID", "clique", "kdown", "mcsplit", "mcsplitdown")
performance$clique[is.na(performance$clique)] <- 1000000

# Test
performance$clique[1] <- 0

# Construct the success data frame
success <- data.frame(ID = features[1],
                      clique = ifelse(!is.na(performance$clique) &&
                                        performance$clique < 1000000, "T", "F"),
                      kdown = ifelse(performance$kdown < 1000000, "T", "F"),
                      mcsplit = ifelse(performance$mcsplit < 1000000, "T", "F"),
                      mcsplitdown = ifelse(performance$mcsplitdown < 1000000, "T", "F"))

data = input(features, performance, success)
folds = cvFolds(data)
model = classify(makeLearner("classif.randomForest"), folds)

times = subset(data$data, T, data$performance)
cols = gray(seq(1, 0, length.out = 255))
image(t(as.matrix(times)), axes = F, col = cols)
axis(1, labels = c("clique", sprintf('k\u2193'), "McSplit", sprintf('McSplit\u2193')), at = seq(0, 1, 1/(length( data$performance ) - 1)), las = 2)
#legend("topleft", legend = c(min(times), max(times)), fill = c("white", "black"), bty = "n", inset = -0.12 , xpd = NA)
