# vim: set et ft=gnuplot sw=4 :

set datafile separator ","
set terminal tikz standalone color size 7cm,4.82cm font '\scriptsize' preamble '\usepackage{times,microtype,algorithm2e,algpseudocode,amssymb}'
set output "gen-graph-both-labels.tex"

set multiplot

set arrow from 1e5, 7140 to screen 0.7, screen 0.6 lw 1 back filled

set arrow from 1e4,7140 to 1e6,7140 front nohead
set arrow from 1e4,8140 to 1e6,8140 front nohead
set arrow from 1e4,7140 to 1e4,8140 front nohead
set arrow from 1e6,7140 to 1e6,8140 front nohead

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
    "../results/both_labels.csv" u 2:($2>=1e6?1e-10:1) smooth cumulative w l notitle lc 1, \
    "../results/both_labels.csv" u 3:($2>=1e6?1e-10:1) smooth cumulative w l notitle lc 2, \
    "../results/both_labels.csv" u 4:($2>=1e6?1e-10:1) smooth cumulative w l notitle lc 3, \
    "../results/both_labels.csv" u 5:($2>=1e6?1e-10:1) smooth cumulative w l notitle lc 4, \
    "../results/both_labels.csv" u 7:($2>=1e6?1e-10:1) smooth cumulative w l notitle lc 4

set size 0.3, 0.3
set origin 0.55, 0.3
set bmargin 0; set tmargin 0; set lmargin 0; set rmargin 0
unset arrow
set border 15
clear

set nokey
set xrange [1e4:1e6]
set yrange [140000:160000]
set xlabel ""
set ylabel ""
set y2label ""
unset xtics
unset ytics
unset y2tics
unset grid

plot \
    "../results/both_labels.csv" u 2:($2>=1e6?1e-10:1) smooth cumulative w l ti '1' at end lc 1, \
    "../results/both_labels.csv" u 3:($2>=1e6?1e-10:1) smooth cumulative w l ti '2' at end lc 2, \
    "../results/both_labels.csv" u 4:($2>=1e6?1e-10:1) smooth cumulative w l ti '3' at end lc 3, \
    "../results/both_labels.csv" u 5:($2>=1e6?1e-10:1) smooth cumulative w l ti '4' at end lc 4, \
    "../results/both_labels.csv" u 7:($2>=1e6?1e-10:1) smooth cumulative w l ti '5' at end lc 5
