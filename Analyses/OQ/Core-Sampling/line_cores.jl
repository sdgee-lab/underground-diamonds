using CairoMakie


include("../merc-transform.jl")

f = CairoMakie.Figure(size = (800, 500))
	
ax = Axis(f[2,1], xlabel = L"Kilometer Point $(m)$", ylabel = L"Vs_{30}\; (m/sec)", limits = (nothing, (200, 450)))

ax2 = Axis(f[1,1], ylabel = L"Mean PGA$(g)$", title = "Mean Surface PGA along tunnel axis", subtitle = "Thessaloniki Metro, Line 1 Track 1")
linkxaxes!(ax, ax2)

ax3 = Axis(f[1, 2], title = "Hazard Curves", subtitle = "New Railway Station", xlabel = L"PGA (g)", ylabel = "Annual PoE", xscale = log10, yscale = log10, yticks = logrange(0.00001, 1, 6))#, ytickformat = LinRange(0.0001, 10, 60))

ax2.width[] = 320; ax3.width[] =ax2.width[]*2/3

inp = "/home/hootseer/Documents/Thesis/data/OQ/line/"

res_1 = CSV.File("output/coreslong_1/hazard_map-mean.csv")
res_128 = CSV.File("output/coreslong_128/hazard_map-mean.csv")
res_1024 = CSV.File("output/coreslong_1024/hazard_map-mean.csv")

res_hc_1 = CSV.File("output/coreslong_1/hazard_curve-mean-PGA.csv")
res_hc_128 = CSV.File("output/coreslong_128/hazard_curve-mean-PGA.csv")
res_hc_1024 = CSV.File("output/coreslong_1024/hazard_curve-mean-PGA.csv")

pn = propertynames(res_hc_1)[4:end]

i = 1 #length(res_a)
imt = map(p -> parse(Float64, p[5:end]), string.(pn))
poe_1 = getproperty.(Ref(res_hc_1[i]), pn)
poe_128 = getproperty.(Ref(res_hc_128[i]), pn)
poe_1024 = getproperty.(Ref(res_hc_1024[i]), pn)

rt_m = CSV.File("route1_measured.csv")

xi = linearize(el_coo(rt_m.lon, rt_m.lat)...)

vs = lines!(ax, xi, rt_m.vs30, linewidth = 2.2, color = :black)

hm_1 = lines!(ax2, xi, res_1.var"PGA-0.0004", linewidth = 2.0, color = :black,)
hm_128 = lines!(ax2, xi, res_128.var"PGA-0.0004", linewidth = 2.0, color = :black, linestyle = :dot)
hm_1024 = lines!(ax2, xi, res_1024.var"PGA-0.0004", linewidth = 2.0, color = :black, linestyle = :dash)

hc_1 = lines!(ax3, imt, poe_1, linewidth = 2.0, color = :black,)
hc_128 = lines!(ax3, imt, poe_128, linewidth = 2.0, color = :black, linestyle = :dot)
hc_1024 = lines!(ax3, imt, poe_1024, linewidth = 2.0, color = :black, linestyle = :dash)


#colsize!(f.layout, 1, Aspect(1., 2.3))

Legend(f[2, 2],
	[hc_1, hc_128, hc_1024],
	["1 Sample", "128 Samples", "1024 Samples"], #, "Site-Measured"],
#	valign = :bottom,
	"Number of Logic Tree Samples",
	)
	
#=Legend(f[1, 2],
	[vs],
	[L"ESRM-Computed"]#, "Site-Measured"]
	)
=#
	
f

save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/longitudinal_samples.png", f)
