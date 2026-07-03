using CairoMakie

include("../merc-transform.jl")

#inp = "/home/hootseer/Documents/underground-diamonds/Analyses/OQ/line/"
#cd(inp)

f = CairoMakie.Figure()

ax = Axis(f[2,1], xlabel = L"Kilometer Point $(m)$", ylabel = L"Vs_{30}\; (m/sec)", limits = (nothing, (200, 450)), xgridvisible = false, ygridvisible = false, xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values])
ax2 = Axis(f[1,1], ylabel = L"Mean PGA $(g)$", title = "Mean PGA", xlabel = L"Kilometer Point $(m)$", xgridvisible = false, ygridvisible = false, xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], limits = (nothing, (0., 1.05)), width = 225)

ax3 = Axis(f[1, 2], title = "Mean PGV", xlabel = L"Kilometer Point $(m)$", ylabel = L"Mean PGV ($m/sec$)", xgridvisible = false, ygridvisible = false, xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], yticks = range(0, 60, 5), limits = (nothing, (0., 70.)), width = 225)#, yscale = log10, yticks = logrange(0.001, 1, 4))#, ytickformat = LinRange(0.0001, 10, 60))

#xlims!(ax3, 0, 10^4+1000)

tightlimits!(ax3)
linkxaxes!(filter(x -> x isa Axis, f.content)...)
#linkxaxes!(ax, ax2)
#linkxaxes!(ax, ax3)
#colgap!(f, 20)

#colsize!(f.layout, 1, Aspect(1., 1.5))

#Label(f[0, :], text = "Thessaloniki Metro, Line 1, Track 1", fontsize = 20)

res = CSV.File("output/line-vs-m/hazard_map-mean.csv")

rt1 = CSV.File("route1_measured.csv")

cor1 = el_coo(rt1.lon, rt1.lat)

#=
lla = LLA.(rt1.lat, rt1.lon)
cords = ECEFfromLLA(wgs84).(lla)
arg_cords = map(i -> map(c -> c[i], cords), 1:3)
=#
#xi = linearize(arg_cords...)

xi = linearize(cor1...)
l = lines!(ax, xi, rt1.vs30, color = :green, linewidth = 2.4)

pga1 = lines!(ax2, xi, res.var"PGA-0.0004"[1:end], color = :blue)
pga2 = lines!(ax2, xi, res.var"PGA-0.00167"[1:end], color = :orange)
pga3 = lines!(ax2, xi, res.var"PGA-0.008"[1:end], color = :red)

pgv1 = lines!(ax3, xi, res.var"PGV-0.0004"[1:end], color = :blue)
pgv2 = lines!(ax3, xi, res.var"PGV-0.00167"[1:end], color = :orange)
pgv3 = lines!(ax3, xi, res.var"PGV-0.008"[1:end], color = :red)

poe = logrange(0.0005, 1., 30)
lst = [:solid, :dash, :dashdot]
lwd = LinRange(2., .8, 3)

depth = [0., 10., 40.]

#hc-d = lines!(ax3, )

Legend(f[2, 2],
	vcat([pga1, pga2, pga3]),
#	vcat(string.("Depth: ", depth, " meters"),
	["Return Period: 2500 years", "Return Period: 600 years", "Return Period: 125 years"],
	#halign = :center, valign = :bottom
	
	)

f


save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/long_pga-pgv.png", f)

