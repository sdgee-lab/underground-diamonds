using CairoMakie

include("../merc-transform.jl")

f = CairoMakie.Figure(size = (800, 500))

ax = Axis(f[2,1], xlabel = L"Tunnel Length $(m)$", ylabel = L"Vs_{30}\; (m/sec)", xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], xgridvisible = false, ygridvisible = false, limits = (nothing, (150, 600)))#, aspect=1)	
ax2 = Axis(f[1,1], ylabel = L"Mean PGA$(g)$", title = "Mean Surface PGA along tunnel axis", subtitle = "Thessaloniki Metro, Line 1 Track 1", xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], xgridvisible = false, ygridvisible = false)
linkxaxes!(ax, ax2)

ax3 = Axis(f[1, 2], title = "Hazard Curves", subtitle = "New Railway Station", xlabel = L"PGA (g)", ylabel = "Annual PoE", xscale = log10, yscale = log10, yticks = logrange(0.00001, 1, 6), xgridvisible = false, ygridvisible = false)#, ytickformat = LinRange(0.0001, 10, 60))

ax.width[] = 320; ax3.width[] =ax.width[]*2/3

inp = "/home/hootseer/Documents/Thesis/data/OQ/line/"

res_a = CSV.File("output/line-vs-a/hazard_map-mean.csv")
res_m = CSV.File("output/line-vs-m/hazard_map-mean.csv")
res_sg = CSV.File("output/line-sg-a/hazard_map-mean.csv")

res_hc_a = CSV.File("output/line-vs-a/hazard_curve-mean-PGA.csv")
res_hc_m = CSV.File("output/line-vs-m/hazard_curve-mean-PGA.csv")
res_hc_sg = CSV.File("output/line-sg-a/hazard_curve-mean-PGA.csv")

pn = propertynames(res_hc_a)[4:end]

i = 1 #length(res_a)
imt = map(p -> parse(Float64, p[5:end]), string.(pn))
poe_PGA_a = getproperty.(Ref(res_hc_a[i]), pn)
poe_PGA_m = getproperty.(Ref(res_hc_m[i]), pn)
poe_PGA_sg = getproperty.(Ref(res_hc_sg[i]), pn)


rt_a = CSV.File("route1_assigned.csv")
rt_m = CSV.File("route1_measured.csv")

xi = linearize(el_coo(rt_a.lon, rt_a.lat)...)

vs_a = lines!(ax, xi, rt_a.vs30, linewidth = 2.0, color = :black, linestyle = :dot)
vs_m = lines!(ax, xi, rt_m.vs30, linewidth = 2.0, color = :black)

hm_a = lines!(ax2, xi, res_a.var"PGA-0.0004", linewidth = 2.0, color = :black, linestyle = :dot)
hm_m = lines!(ax2, xi, res_m.var"PGA-0.0004", linewidth = 2.0, color = :black)
hm_sg = lines!(ax2, xi, res_sg.var"PGA-0.0004", linewidth = 2.0, color = :black, linestyle = :dash)

hc_a = lines!(ax3, imt, poe_PGA_a, linewidth = 2.0, color = :black, linestyle = :dot)
hc_m = lines!(ax3, imt, poe_PGA_m, linewidth = 2.0, color = :black)
hc_sg = lines!(ax3, imt, poe_PGA_sg, linewidth = 2.0, color = :black, linestyle = :dash)


#colsize!(f.layout, 1, Aspect(1., 2.3))

Legend(f[2, 2],
	[vs_m, vs_a, hc_sg],
	["Site-Measured", "ESRM-Assigned", "ESRM Slope-Geology"], #, "Site-Measured"],
#	valign = :bottom,
	"Calculations for 2500 years Return Period",
	)
	
#=Legend(f[1, 2],
	[vs],
	[L"ESRM-Computed"]#, "Site-Measured"]
	)
=#
	
f

save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/method_comparison.png", f)
