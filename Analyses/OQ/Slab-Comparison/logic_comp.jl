using CSV
using CairoMakie

hc_w = CSV.File("output/with-pgv/hazard_curve-mean-PGA.csv")
hc_wout = CSV.File("output/without-pgv/hazard_curve-mean-PGA.csv")

imt = logrange(.0005, 3., 30)
poe_w = map(i -> hc_w[1][i], 4:length(hc_w[1]))
poe_wout = map(i -> hc_wout[1][i], 4:length(hc_wout[1]))

f = Figure()
ax = Axis(f[1, 1], xscale = log10, yscale = log10, title = "PGA Hazard Curves", subtitle = "New Railway Station", ylabel = "Annual Probability of Exceedance", xlabel = L"PGA ($g$)", xgridvisible = false, ygridvisible = false, yticks = logrange(0.0001, 1, 5), xticks = logrange(0.001, 1, 4))

hc_w = lines!(ax, imt, poe_w, color = :red, linestyle = :dashdot)
hc_wout = lines!(ax, imt, poe_wout, color = :blue, linestyle = :dash)

Legend(f[1, 2],
	[hc_w, hc_wout],
	["With PGV Ability", "Without PGV Ability"], #, "Site-Measured"],
#	valign = :bottom,"
	)

save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/logic_tree_comparison.png", f)

