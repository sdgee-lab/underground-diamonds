using CSV
using CairoMakie
using Polynomials

f = Figure()
ax = Axis(f[1,1], xscale = log2, xgridvisible = false, ygridvisible = false,
  xlabel = "Number of Logic Tree Samples",
  ylabel = L"PGA ($g$)",
  title = "Estimated PGA for incremental Logic Tree Samples",
  subtitle = "New Railway Station"
)

inp = "/home/hootseer/Documents/underground-diamonds/Analyses/OQ/Core-Sampling/output/cores"

i = 0:14
cores::Vector{Float64} = 2 .^i
pgas::Vector{Float64} = []


for i in cores
  #cd(string(inp, Int(i)))
  fl = CSV.File(string(inp, Int(i),"/hazard_map-mean.csv"))

  push!(pgas, fl.var"PGA-0.0004"[1])
end

#cd("../..")

scatter!(ax, cores, pgas, color=:black, label = "Calculated Values")#, markersize=9)

n = 8
xi = 0:0.1:14
pli = fit(log2.(cores), pgas, n)
fit_pgasi = pli.(xi)
lines!(ax, 2 .^xi, fit_pgasi, color = :black, label = string(n, " Degree Polynomial"))
#lines!(axx, xi, fit_pgasi, labels = string(n, " Degree Polynomial"))

L = axislegend(ax)

lines!(ax, cores, pgas, color=:black, linestyle=:dash, linewidth=1.0, alpha=0.8)

f

save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/core_number.png", f)

