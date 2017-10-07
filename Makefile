MCSPLIT_HEURISTIC := min_max # min_max or min_product
TIMEOUT := 5
HOW_MANY := 10

# add -a to mcsplit to make it use vertex and edge labels
define run_algorithms
echo $1, `./algorithms/mcsplit/mcsp --timeout=$(TIMEOUT)$2 -q $(MCSPLIT_HEURISTIC)$1` >> results/mcsplit.csv
echo $1, `./algorithms/kdown/solve_subgraph_isomorphism sequentialix --timeout $(TIMEOUT) --format $3 $1` >> results/kdown.csv
#echo $1, `./algorithms/clique/solve_max_common_subgraph --timeout $(TIMEOUT) $1` >> results/clique.csv
endef

define run_sip
$(call run_algorithms,$(1), -l,lad)
endef

define run_mcs
$(call run_algorithms,$(1),,vf)
endef

define generate_pairs
$(foreach p,$(wildcard $(1)),$(foreach t,$(wildcard $(2)),$(subst /,_,$(3).$p.$t)))
endef

#data: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/si/*/*))
#data: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/scalefree/*))
#data: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/phase/*-target))
#data: $(call generate_pairs,data/sip-instances/meshes-CVIU11/patterns/*,data/sip-instances/meshes-CVIU11/targets/*,MESH)
#data: $(call generate_pairs,data/sip-instances/LV/*,data/sip-instances/LV/*,LV)
#data: $(call generate_pairs,data/sip-instances/largerGraphs/*,data/sip-instances/largerGraphs/*,LARGER)
#data: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/images-PR15/pattern*))
#data: $(call generate_pairs,data/sip-instances/images-CVIU11/patterns/*,data/sip-instances/images-CVIU11/targets/*,IMAGE)

#data: $(addsuffix /TRGT,$(foreach f,$(wildcard data/mcs-instances/*/*/*),$(wordlist 1,$(HOW_MANY),$(wildcard $f/*A*))))
data: $(addsuffix /TRGT,$(foreach f,$(foreach s,10 30 50,$(wildcard data/mcs-instances/mcs$s/*/*)),$(wordlist 1,$(HOW_MANY),$(wildcard $f/*A*))))

# column names: nodes, time, size
data:
	sed -i 's/^\([^,]\+,\)[^0-9]\+\([0-9]\+\)[^:]\+:\s\([0-9]\+\)[^0-9]\+\([0-9]\+\).*/\1\3,\4,\2/g' results/mcsplit.csv
	sed -i 's/^\([^,]\+,\)[^0-9]\+\([0-9]\+\)\(\s([^)]\+)\)*[^0-9]\+\([0-9]\+\)[^S]\+\(SIZE=\)\?/\1\2,\4,/g' results/kdown.csv
	sed -i 's/^\([^,]\+,\)[^0-9]\+\([0-9]\+\)[^0-9]\+\([0-9]\+\)\(\s([^)]\+)\)*\s\([0-9]\+\)/\1\2,\5,\3/g' results/clique.csv

data/sip-instances/si/%/MAKE_TARGET: data/sip-instances/si/%/pattern data/sip-instances/si/%/target
	$(call run_sip,$^)

data/sip-instances/scalefree/%/MAKE_TARGET: data/sip-instances/scalefree/%/pattern data/sip-instances/scalefree/%/target
	$(call run_sip,$^)

data/sip-instances/phase/%/MAKE_TARGET: data/sip-instances/phase/$(subst -target,-pattern,%) data/sip-instances/phase/%
	$(call run_sip,$^)

data/sip-instances/images-PR15/%/MAKE_TARGET: data/sip-instances/images-PR15/% data/sip-instances/images-PR15/target
	$(call run_sip,$^)

MESH% LV% LARGER% IMAGE%:
	$(call run_sip,$(subst _,/,$(word 2,$(subst ., ,$@)) $(word 3,$(subst ., ,$@))))

data/mcs-instances/%/TRGT:
	$(call run_mcs,$(subst /TRGT,,$@ $(subst A,B,$@)))
