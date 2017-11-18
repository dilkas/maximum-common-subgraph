require(llama)

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
performance$kdown <- pmin(performance$kdown, 1000000)
performance$mcsplit <- pmin(performance$mcsplit, 1000000)
performance$mcsplitdown <- pmin(performance$mcsplitdown, 1000000)
performance <- performance[performance$clique < 1000000 | performance$kdown < 1000000 | performance$mcsplit < 1000000 | performance$mcsplitdown < 1000000, ]
features <- features[features$ID %in% performance$ID,]

# Construct the success data frame
success <- cbind(performance)
success$clique <- ifelse(success$clique < 1000000, "T", "F")
success$kdown <- ifelse(success$kdown < 1000000, "T", "F")
success$mcsplit <- ifelse(success$mcsplit < 1000000, "T", "F")
success$mcsplitdown <- ifelse(success$mcsplitdown < 1000000, "T", "F")

data = input(features, performance, success)
folds = cvFolds(data)
model = classify(makeLearner("classif.randomForest"), folds)

# Plots
times = subset(data$data, T, data$performance)
cols = gray(seq(1, 0, length.out = 255))
labels = c("clique", sprintf('k\u2193'), "McSplit", sprintf('McSplit\u2193'))

# Runtimes by solver and instance
image(t(as.matrix(times)), axes = F, col = cols)
axis(1, labels = labels, at = seq(0, 1, 1/(length( data$performance ) - 1)), las = 2)

# Log runtimes by solver and instance
image(log10(t(as.matrix(times))), axes = F, col = cols)
axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance) - 1)), las = 2)

# White - first, black - last (filtered)
image(apply(times , 1, order), axes = F, col = cols)
axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance) - 1)), las = 2)

# How many times is each algorithm the best?
length(which(times$clique < times$kdown & times$clique < times$mcsplit & times$clique < times$mcsplitdown))
length(which(times$kdown < times$clique & times$kdown < times$mcsplit & times$kdown < times$mcsplitdown))
length(which(times$mcsplit < times$clique & times$mcsplit < times$kdown & times$mcsplit < times$mcsplitdown))
length(which(times$mcsplitdown < times$clique & times$mcsplitdown < times$kdown & times$mcsplitdown < times$mcsplit))

# Heatmaps for pattern/target features. Group differently?
features = subset(data$data, T, data$features)
nFeatures = normalize(features)
graph_feature_names <- c("vertices", "edges", "loops", "mean degree", "max degree", "SD of degrees", "density", "connected", "mean distance", "max distance", "distance \u2265 2", "distance \u2265 3", "distance \u2265 4")
full_feature_names = c(paste("pattern", graph_feature_names), paste("target", graph_feature_names))
par(mar = c(1, 10, 1, 1))
image(as.matrix(nFeatures$features), axes = F, col = cols)
axis(2, labels = full_feature_names, at = seq(0, 1, 1/(length(data$features) - 1)), las = 2)

