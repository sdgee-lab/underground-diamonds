using CSV
using CairoMakie

rt1 = CSV.File("route1_measured.csv")

pga = CSV.File("output/line-vs-m/hazard_curve-mean-PGA.csv")
pgv = CSV.File("output/line-vs-m/hazard_curve-mean-PGV.csv")

n = 366

imt_a = logrange(.0005, 3., 30)
imt_v = logrange(.5, 10., 30)
poe_a = map(i -> pga[n][i], 4:length(pga[n]))
poe_v = map(i -> pgv[n][i], 4:length(pgv[n]))

pga_f = Figure()
pga_ax = Axis(pga_f[1, 1], xscale = log10, yscale = log10, title = "PGA Hazard Curve", subtitle = "Kilometric Position 8+550", ylabel = "Annual Probability of Exceedance", xlabel = L"PGA ($g$)", xgridvisible = false, ygridvisible = false, yticks = logrange(0.0001, 1, 5), xticks = logrange(0.001, 1, 4))

lines!(pga_ax, imt_a, poe_a, color = :black)

pgv_f = Figure()

pgv_ax = Axis(pgv_f[1, 1], xscale = log10, yscale = log10, title = "PGV Hazard Curve", subtitle = "Kilometric Position 8+550", ylabel = "Annual Probability of Exceedance", xlabel = L"PGV ($cm/sec$)", xgridvisible = false, ygridvisible = false, yticks = logrange(0.0001, 1., 5), xticks = logrange(0.001, 100, 6),)# limits = (nothing, (0.001, .6)))

lines!(pgv_ax, imt_v, poe_v, color = :black)


pgv_f
save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/PGV_hc_8550.png", pgv_f)
save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/PGA_hc_8550.png", pga_f)

