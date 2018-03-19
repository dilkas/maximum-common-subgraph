# Algorithm Selection for Maximum Common Subgraph

NOTE: the `models` directory is too large to be on GitHub, and (for a while) can be downloaded from [Google Drive](https://drive.google.com/drive/folders/1YKQlTZPxYIHjLtq1-tq2fdtiy7NYf3ua?usp=sharing).

## Directory Structure

* `algorithms`: the three original algorithms (clique, kdown, McSplit), and a combination of McSplit and clique called Fusion.
* `data`: two databases of graphs for MCS and SIP algorithms, and an AIDS dataset, which was never used.
* `graph_stats`: a graph feature extractor taken from Kotthoff, McCreesh, and Solnon, 2016. Portfolios of subgraph isomorphism algorithms.
* `results`: all (mostly CSV) data that was generated during this project.
  * `.mcs.` and `.sip.` denote which database the data came from.
  * a number between dots denotes the labelling percentage.
  * `both.labels` means that both vertices and edges were labelled.
  * `vertex.labels` means that only vertex labels were labelled.
  * `association` files record features of the association graph.
  * `clique` files record the number of search nodes, runtime, and the size of the discovered MCS, for the clique algorithm.
  * `kdown`, `mcsplit`, and `mcsplitdown` do the same thing for other algorithms.
  * `costs.csv` records the feature extraction costs, for all graphs.
  * `filtered_instances` is a random sample of MCS instances (30,000).
  * `filtered_instances2` is a random sample of `filtered_instances` (10,000).
  * `filtered_instances_one_filename` is `filtered_instances` without the second of the two filenames.
  * `fusion1` is the Fusion algorithm that switches after one decision.
  * `fusion2` is the Fusion algorithm that switches after two decisions.
  * `labels.csv`: each line corresponds to a different graph of the MCS instances. For each distinct label in the 33% labelling scheme, we record the number of vertices with that label.
  * `mcs_features.csv` and `sip_features.csv` record the features for unlabelled MCS and SIP instances (ratio features are calculated later).
  * `mcs_features_individual.csv` and `sip_features_individual.csv` record features of each individual graph separately.
  * `mcs_instances` and `sip_instances` contain the complete lists of instances, for both graph databases.
* `text`: the dissertation, a short status report, and three sets of slides for different presentations.
* `video`: everything related to the video describing this project.
