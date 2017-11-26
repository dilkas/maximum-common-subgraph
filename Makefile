MCSPLIT_HEURISTIC := min_max # min_max or min_product
TIMEOUT := 1000

# limits for clique (>= and <)
MIN_SIZE := 0
MAX_SIZE := 30000

# memory limits for clique
MEMORY_LIMIT := 7340032

# add -a to mcsplit to make it use vertex and edge labels
define run_sip
#echo $1, `./algorithms/mcsplit/mcsp --timeout=$(TIMEOUT) -l -q $(MCSPLIT_HEURISTIC)$1` >> results/mcsplit.csv
#echo $1, `./algorithms/kdown/solve_subgraph_isomorphism sequentialix --timeout $(TIMEOUT) --format lad --induced $1` >> results/kdown.csv
size=$(shell echo $(shell head -n 1 $(firstword $1)) \* $(shell head -n 1 $(word 2,$1)) | bc) ; \
if [ $${size} -lt $(MAX_SIZE) -a $${size} -ge $(MIN_SIZE) ] ; then \
	echo $1, `ulimit -v $(MEMORY_LIMIT) ; ./algorithms/clique/solve_max_common_subgraph --unlabelled --undirected --lad --timeout $(TIMEOUT) $1` >> results/clique.csv ;\
fi
#echo $1 `./graph_stats/graph_stats --distances $(firstword $1)` `./graph_stats/graph_stats --distances $(word 2,$1)` >> results/features.csv
#echo $1 >> results/sip_instances
endef

define run_mcs
#echo $1, `./algorithms/mcsplit/mcsp --timeout=$(TIMEOUT) -q $(MCSPLIT_HEURISTIC)$1` >> results/mcsplit.csv
#echo $1, `./algorithms/kdown/solve_subgraph_isomorphism sequentialix --timeout $(TIMEOUT) --format vf --induced $1` >> results/kdown.csv
echo $1, `ulimit -v $(MEMORY_LIMIT) ; ./algorithms/clique/solve_max_common_subgraph --unlabelled --undirected --timeout $(TIMEOUT) $1` >> results/clique.csv
#echo $1 `./graph_stats/graph_stats --vf --distances $(firstword $1)` `./graph_stats/graph_stats --distances $(word 2,$1)` >> results/features.csv
#echo $1 >> results/mcs_instances
endef

define generate_pairs
$(foreach p,$(wildcard $(1)),$(foreach t,$(wildcard $(2)),$(subst /,_,$(3).$p.$t)))
endef

#main: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/si/*/*))
#main: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/scalefree/*))
#main: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/phase/*-target))
#main: $(call generate_pairs,data/sip-instances/meshes-CVIU11/patterns/*,data/sip-instances/meshes-CVIU11/targets/*,MESH)
#main: $(call generate_pairs,data/sip-instances/LV/*,data/sip-instances/LV/*,LV)
#main: $(call generate_pairs,data/sip-instances/largerGraphs/*,data/sip-instances/largerGraphs/*,LARGER)
main: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/images-PR15/pattern*))
#main: $(call generate_pairs,data/sip-instances/images-CVIU11/patterns/*,data/sip-instances/images-CVIU11/targets/*,IMAGE)

#main: $(addsuffix /TRGT,$(foreach f,$(wildcard data/mcs-instances/*/*/*),$(wildcard $f/*A*)))
#main: $(addsuffix /TRGT,$(wildcard data/mcs-instances/*/*/*/*))

# column names: nodes, time, size
parse:
	#sed -i 's/^\([^,]\+,\)[^0-9]\+\([0-9]\+\)[^:]\+:\s\([0-9]\+\)[^0-9]\+\([0-9]\+\).*/\1\3,\4,\2/g' results/mcsplit.csv
	sed -i 's/^\([^,]\+,\)[^0-9]\+\([0-9]\+\)[^0-9]\+\([0-9]\+\)\(\s([^)]\+)\)*\s\([0-9]\+\)/\1\2,\5,\3/g' results/clique.csv
	#sed -i 's/^\([^,]\+,\)[^0-9]\+\([0-9]\+\)\(\s([^)]\+)\)*[^0-9]\+\([0-9]\+\)[^S]\+\(SIZE=\)\?/\1\2,\4,/g' results/kdown.csv
	#sed -i 's/,$$/,0/g' results/kdown.csv
	#sed -i 's/ [a-z0-9]\+ = /,/g' results/features.csv

data/sip-instances/si/%/MAKE_TARGET: data/sip-instances/si/%/pattern data/sip-instances/si/%/target
	$(call run_sip,$^)

data/sip-instances/scalefree/%/MAKE_TARGET: data/sip-instances/scalefree/%/pattern data/sip-instances/scalefree/%/target
	$(call run_sip,$^)

data/sip-instances/phase/%/MAKE_TARGET:
	$(call run_sip,$(subst /MAKE_TARGET,,$(subst -target,-pattern,$@) $@))

data/sip-instances/images-PR15/%/MAKE_TARGET: data/sip-instances/images-PR15/% data/sip-instances/images-PR15/target
	$(call run_sip,$^)

MESH% LV% LARGER% IMAGE%:
	$(call run_sip,$(subst _,/,$(word 2,$(subst ., ,$@)) $(word 3,$(subst ., ,$@))))

data/mcs-instances/%/TRGT:
	$(call run_mcs,$(subst /TRGT,,$@ $(subst A,B,$@)))

#data/mcs-instances/%/TRGT:
#	echo $(subst /TRGT,,$@)`./graph_stats/graph_stats --vf --distances $(subst /TRGT,,$@)` >> results/features.csv
