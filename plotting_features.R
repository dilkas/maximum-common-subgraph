sip <- read.csv("results/sip_features.csv", header = FALSE)
colnames(sip) <- c("vertices", "edges", "loops", "meandeg", "maxdeg", "stddeg", "density", "isconnected", "meandistance", "maxdistance", "proportiondistancege2", "proportiondistancege3", "proportiondistancege4")
