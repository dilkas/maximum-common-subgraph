data <- read.csv("results/costs.csv", header = FALSE)
names(data) <- c("filenames", "time")
attach(data)

sip_instances <- data$time[startsWith(as.character(data$filenames), "data/sip")]

summary(sip_instances)
