using CairoMakie
#using GLMakie
#using CSV

include("../OQ/merc-transform.jl")
	
s = CSV.File("surface.csv")
er = CSV.File("erythra.csv")

rt1 = CSV.File("../OQ/line/route1_measured.csv")

cor1 = el_coo(rt1.lon, rt1.lat)

xi = linearize(cor1...)

vs30 = [234, 277, 316]
depths = [24, 21, 14]
l_c = [4250-435, 430+7120-4250, xi[end] - 7120]

sections = [0, 430, 430, 4250, 4250, 7120, 7120, xi[end]]

f = Figure()
ax = Axis(f[1,1], xlabel = L"Kilometer Point $(m)$", ylabel = L"Depth\; ($m$)", xgridvisible = false, ygridvisible = false, xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], width = 490, )


#lines!(ax, s.KP, s.Surface)
#lines!(ax, er.KP, er.Er)

#scor = el_coo(s.KP, s.Surface)

d = s.Surface .- er.Er 

dl = lines!(ax, s.KP, d, color = :black, linestyle = :dash)
dlm = lines!(ax, sections, [depths[2], depths[2], depths[1], depths[1], depths[2], depths[2], depths[3], depths[3]], color = :black)

d_m = round(sum(d)/length(d))
d_c = round(sum(depths .* l_c/xi[end]))

#text!(axg, 1000, 420, text = "Test")
Legend(
	f[1,1],
	[dlm, dl],
	[L"%$(d_c) ($m$)", L"%$(d_m) ($m$)"],
	L"Average Depth",
	halign = :right,
	valign = :top,
	margin = [10, 10, 10, 10]
	)

g = Figure()
axg = Axis(g[1,1], xlabel = L"Kilometer Point $(m)$", ylabel = L"Vs_{30}\; (m/sec)", limits = (nothing, (200, 450)), xgridvisible = false, ygridvisible = false, xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], width = 490)


vsm = lines!(axg, sections, [vs30[2], vs30[2], vs30[1], vs30[1], vs30[2], vs30[2], vs30[3], vs30[3]], color = :black, linewidth = 2.2)
l = lines!(axg, xi, rt1.vs30, linewidth = 2.4, color = :black, linestyle = :dash)

av_m = round(sum(rt1.vs30)/length(rt1))
av_c = round(sum(vs30 .* l_c/xi[end]))

#text!(axg, 1000, 420, text = "Test")
Legend(
	g[1,1],
	[l, vsm],
	[L"%$(av_c) ($m/sec$)", L"%$(av_m) ($m/sec$)"],
	L"Average $V_{s30}$",
	halign = :left,
	valign = :top,
	margin = [10, 10, 10, 10]
	)

f
#g
save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/risk/depth.png", f)
save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/risk/vs30.png", g)
