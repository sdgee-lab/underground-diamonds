using CairoMakie
#using GLMakie
#using CSV

include("../OQ/merc-transform.jl")
	
s = CSV.File("surface.csv")
er = CSV.File("erythra.csv")

rt1 = CSV.File("../OQ/line/route1_measured.csv")

cor1 = el_coo(rt1.lon, rt1.lat)

xi = linearize(cor1...)

vs30 = [239, 310, 400]
depths = [24, 21, 14]
l_c = [4250-435, 430+7120-4250, xi[end] - 7120]

sections = [0, 430, 430, 4250, 4250, 7120, 7120, xi[end]]

w = 370
f = Figure(size = (900, 400))
g = Figure(size = (910, 400))
# changed f[1,1] to g[1,2]
ax = Axis(g[1,2], xlabel = L"Kilometer Point $(m)$", ylabel = L"Depth\; ($m$)", xgridvisible = false, ygridvisible = false, xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], width = w, )


#lines!(ax, s.KP, s.Surface)
#lines!(ax, er.KP, er.Er)

#scor = el_coo(s.KP, s.Surface)

d = s.Surface .- er.Er 

dl = lines!(ax, s.KP, d, color = :black, linestyle = :dash)
dlm = lines!(ax, sections, [depths[2], depths[2], depths[1], depths[1], depths[2], depths[2], depths[3], depths[3]], color = :black)

d_m = round(sum(d)/length(d), digits=1)
d_c = round(sum(depths .* l_c/xi[end]), digits=1)

#text!(axg, 1000, 420, text = "Test")
#changed f to g
Legend(
	g[1,2],
	[dlm, dl],
	[L"%$(d_c) ($m$)", L"%$(d_m) ($m$)"],
	"Average Depth",
	halign = :right,
	valign = :top,
	margin = [10, 10, 10, 10]
	)

axg = Axis(g[1,1], xlabel = L"Kilometer Point $(m)$", ylabel = L"Vs_{30}\; (m/sec)", limits = (nothing, (200, 450)), xgridvisible = false, ygridvisible = false, xtickformat = values -> ["$(Int64(round(value/1000, RoundDown)))+000" for value in values], width = w)


vsm = lines!(axg, sections, [vs30[2], vs30[2], vs30[1], vs30[1], vs30[2], vs30[2], vs30[3], vs30[3]], color = :black, linewidth = 2.2)
l = lines!(axg, xi, rt1.vs30, linewidth = 2.4, color = :black, linestyle = :dash)

av_m = round(sum(rt1.vs30)/length(rt1), digits = 1)
av_c = round(sum(vs30 .* l_c/xi[end]), digits = 1)

#text!(axg, 1000, 420, text = "Test")
Legend(
	g[1,1],
	reverse([l, vsm]),
	([L"%$(av_c) ($m/sec$)", L"%$(av_m) ($m/sec$)"]),
	L"Average $V_{s30}$",
	halign = :left,
	valign = :top,
	margin = [10, 10, 10, 10]
	)

#f
g

save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/fragility/comparison.png", g)
#save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/risk/depth.png", f)
#save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/risk/vs30.png", g)


function find_vs30(t::Vector{Float64}, vs::Vector{Float64}, d::Float64 = 30.)
  
  st::Vector{Float64} = map(i -> sum(t[1:i]), 1:length(t))
  ind = findfirst(st .> d)
  vsd::Float64 = 0
  
  if isnothing(ind)
    vsd = vs[1]
  else
    vs = vs[1:ind]
    t = [t[1:ind-1]; d - sum(t[1:ind-1])]
    vsd = sum(t)/sum(t./vs)
    
  end
  
  return vsd
  
end
