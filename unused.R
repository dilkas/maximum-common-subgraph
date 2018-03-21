# Pieces of code that are no longer maintained

# Log runtimes by solver and instance
png(paste0("dissertation/images/", type, "_runtime_heatmap.png"), width = 480,
    height = 320)
image(log10(t(as.matrix(data$performance))), axes = F, col = cols)
axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance))),
     las = 2)
dev.off()

# White - first, black - last (weird results because of equal timing out values)
image(apply(times , 1, order), axes = F, col = cols)
axis(1, labels = labels, at = seq(0, 1, 1/(length(data$performance) - 1)),
     las = 2)

# Tables for best algorithms
times <- performance[grep("data/sip-instances/images-CVIU11", performance$ID), ]
times <- performance[grep("data/sip-instances/images-PR15", performance$ID), ]
times <- performance[grep("data/sip-instances/largerGraphs", performance$ID), ]
times <- performance[grep("data/sip-instances/LV", performance$ID), ]
times <- performance[grep("data/sip-instances/meshes-CVIU11", performance$ID), ]
times <- performance[grep("data/sip-instances/phase", performance$ID), ]
times <- performance[grep("data/sip-instances/scalefree", performance$ID), ]
times <- performance[grep("data/sip-instances/si", performance$ID), ]
times <- performance[grep("data/mcs-instances", performance$ID), ]

# How many times is each algorithm the best?
times = performance
length(which(times$clique <= times$mcsplit & times$clique <= times$mcsplitdown))
length(which(times$mcsplit <= times$clique & times$mcsplit <= times$mcsplitdown))
length(which(times$mcsplitdown <= times$clique &
               times$mcsplitdown <= times$mcsplit))
summary(times[!(times$clique < times$kdown & times$clique < times$mcsplit &
                  times$clique < times$mcsplitdown) &
                !(times$kdown < times$clique & times$kdown < times$mcsplit &
                    times$kdown < times$mcsplitdown) &
                !(times$mcsplit < times$clique & times$mcsplit < times$kdown &
                    times$mcsplit < times$mcsplitdown) &
                !(times$mcsplitdown < times$clique &
                    times$mcsplitdown < times$kdown &
                    times$mcsplitdown < times$mcsplit), ])

# Heatmaps for pattern/target features. Group differently?
features <- subset(data$data, T, data$features)
nFeatures <- normalize(features)
graph_feature_names <- c("vertices", "edges", "loops", "mean degree",
                         "max degree", "SD of degrees", "density", "connected",
                         "mean distance", "max distance", "distance \u2265 2",
                         "distance \u2265 3", "distance \u2265 4")
full_feature_names <- c(paste("pattern", graph_feature_names),
                        paste("target", graph_feature_names))
par(mar = c(1, 10, 1, 1))
image(as.matrix(nFeatures$features), axes = F, col = cols)
axis(2, labels = full_feature_names,
     at = seq(0, 1, 1/(length(data$features) - 1)), las = 2)

# Using ggplot2 for ECDF

library(ggplot2)
x <- c()
g <- c()
for (algorithm in algorithms) {
  x <- c(x, times[, algorithm])
  g <- c(g, rep(algorithm, length(times[, algorithm])))
}
g <- g[x > 0]
x <- x[x > 0]
df <- data.frame(x = x, g = g)
png(paste0("dissertation/images/ecdf_", type, "_llama_ggplot2.png"),
    width = 480, height = 320)
(ggplot(df, aes(x, color = g)) + stat_ecdf(geom = "step", pad = FALSE)
  + scale_x_log10())
dev.off()

png(paste0("dissertation/images/ecdf_", type, ".png"), width = 480, height = 320)
plt <- ecdfplot(~ clique + mcsplit + mcsplitdown + vbs, data = times,
               auto.key = list(space = "right", text = labels[-6]),
               xlab = "Runtime (ms)", ylim = c(0.4, 1), main = type_label)
update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8, name = "Dark2")))
dev.off()

sum(times$clique <= times$vbs)
#times2 <- times[startsWith(as.character(times$ID), "data/sip-instances/"),]
times2 <- times[startsWith(as.character(times$ID), "data/mcs-instances/"),]
png("dissertation/images/ecdf_mcs.png", width = 480, height = 320)
plt <- ecdfplot(~ clique + kdown + mcsplit + mcsplitdown, data = times2,
                auto.key = list(space = "right",
                                text = c("clique", "k\u2193", "McSplit",
                                         "McSplit\u2193")),
                xlab = "Runtime (ms)", main = "Unlabelled")
update(plt, par.settings = custom.theme(fill = brewer.pal(n = 8,
                                                          name = "Dark2")))
dev.off()
