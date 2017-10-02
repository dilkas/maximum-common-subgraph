MCSPLIT_HEURISTIC := min_max # min_max or min_product

define run_algorithms
echo $@, `./algorithms/mcsplit/mcsp -l -q $(MCSPLIT_HEURISTIC)$^` >> results/mcsplit.csv
echo $@, `./algorithms/kdown/solve_subgraph_isomorphism sequentialix --format lad $^ | tail -1 | awk -F'[ =]' '{print $$4}'` >> results/kdown.csv
echo $@, `./algorithms/clique/solve_max_common_subgraph $^` >> results/clique.csv
endef

unlabelled: $(addsuffix /MAKE_TARGET,$(wildcard data/sip-instances/si/*/*) $(wildcard data/sip-instances/scalefree/*) $(wildcard data/sip-instances/phase/*-target))

data/sip-instances/si/%/MAKE_TARGET: data/sip-instances/si/%/pattern data/sip-instances/si/%/target
	$(call run_algorithms)

data/sip-instances/scalefree/%/MAKE_TARGET: data/sip-instances/scalefree/%/pattern data/sip-instances/scalefree/%/target
	$(call run_algorithms)

data/sip-instances/phase/%/MAKE_TARGET: data/sip-instances/phase/$(subst -target,-pattern,%) data/sip-instances/phase/%
	$(call run_algorithms)

#data/sip-instances/meshes-CVIU11/
