# vim: set et ft=gnuplot sw=4 :

set datafile separator ","
set terminal tikz standalone color size 7cm,4.82cm font '\scriptsize' preamble '\usepackage{times,microtype,algorithm2e,algpseudocode,amssymb}'
set output "gen-graph-both-labels.tex"

set xlabel "Runtime (ms)"
set ylabel "Number of Instances Solved"
set border 3
set grid x y
set xtics nomirror
set ytics nomirror
set xrange [1:1e6]
set logscale x
set format x '$10^{%T}$'
set key off

plot \
    "< cat ../results/mcsplit.both.labels.5.csv ../results/mcsplit.both.labels.10.csv ../results/mcsplit.both.labels.15.csv" u 2:($2>=1e6?1e-10:1) smooth cumulative w l ti '\textsc{McSplit}' at end lc 1, \
    "< cat ../results/clique.both.labels.5.csv ../results/clique.both.labels.10.csv ../results/clique.both.labels.15.csv" u 2:($2>=1e6?1e-10:1) smooth cumulative w l ti 'clique' at end lc 2, \
    "< cat ../results/mcsplitdown.both.labels.5.csv ../results/mcsplitdown.both.labels.10.csv ../results/mcsplitdown.both.labels.15.csv" u 2:($2>=1e6?1e-10:1) smooth cumulative w l ti '$\textsc{McSplit}{\downarrow}$' at end lc 3
