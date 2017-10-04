MCSPLIT_HEURISTIC := min_max # min_max or min_product

define run_sip
#echo $1, `./algorithms/mcsplit/mcsp -l -q $(MCSPLIT_HEURISTIC)$1` >> results/mcsplit.csv
echo $1, `./algorithms/kdown/solve_subgraph_isomorphism sequentialix --format lad $1 | tail -1 | awk -F'[ =]' '{print $$4}'` >> results/kdown.csv
#echo $1, `./algorithms/clique/solve_max_common_subgraph $1` >> results/clique.csv
endef

define run_mcs
echo $1, `./algorithms/mcsplit/mcsp -q $(MCSPLIT_HEURISTIC)$1` >> results/mcsplit.csv
#echo $1, `./algorithms/kdown/solve_subgraph_isomorphism sequentialix --format vf $1 | tail -1 | awk -F'[ =]' '{print $$4}'` >> results/kdown.csv
#echo $1, `./algorithms/clique/solve_max_common_subgraph $1` >> results/clique.csv
endef

define generate_pairs
$(foreach p,$(wildcard $(1)),$(foreach t,$(wildcard $(2)),$(subst /,_,$(3).$p.$t)))
endef

#unlabelled: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/si/*/*))
#unlabelled: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/scalefree/*))
#unlabelled: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/phase/*-target))
#unlabelled: $(call generate_pairs,data/sip-instances/meshes-CVIU11/patterns/*,data/sip-instances/meshes-CVIU11/targets/*,MESH)
#unlabelled: $(call generate_pairs,data/sip-instances/LV/*,data/sip-instances/LV/*,LV)
#unlabelled: $(call generate_pairs,data/sip-instances/largerGraphs/*,data/sip-instances/largerGraphs/*,LARGER)
#unlabelled: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/images-PR15/pattern*))
#unlabelled: $(call generate_pairs,data/sip-instances/images-CVIU11/patterns/*,data/sip-instances/images-CVIU11/targets/*,IMAGE)
labelled: $(addsuffix /TRGT,$(wildcard data/mcs-instances/*/*/*/*A*))

parse:
	sed -i 's/^\([^,],\)[^0-9]\([0-9]+\)[^a-zA-Z]Nodes:\s\([0-9]+\)[^0-9]+\([0-9]+\)$/\1\2,\3,\4/g' results/mcsplit.csv

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
