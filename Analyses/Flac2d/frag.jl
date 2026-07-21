using Distributions
using CairoMakie

function fragility(pgaimed, pgvimed, β1, β2, name)
  
  global f = Figure(size=(800,400))
  ax = Axis(f[1,1], limits = ((0, 1.6), (0.0, 1.0)), yticks = 0:0.2:1.0, xticks=0.0:.4:1.6, xgridvisible = false, ygridvisible=false, xlabel = "PGA (g)", ylabel = "Probability of Damage")
  ax2 = Axis(f[1,2], limits = ((0, 0.6), (0.0, 1.0)), yticks = 0:0.2:1.0, xticks=0:0.2:.6, xgridvisible = false, ygridvisible=false, xlabel = L"PGV ($m/sec$)")
  ia = 0:0.01:1.6
  iv = 0.0:0.01:1.0
  #i = 0:0.1:20
  #imed = [1.645, 1.961, 5.554]
  #imed = [[1,2,3], [1,2,3], [1,2,3]]
  #β = [[1,2,3], [1,2,3], [1,2,3]]
  
  #pgaimed = [1.581, 1.754, 3.498]
  #pgaβ = .411
  #pgvimed = [.315, .368, 1.029]
  #pgvβ = .749
  #β = .535
  #β = 0.996

  ln = LogNormal.(log.(pgaimed), β1)
  ln2 = LogNormal.(log.(pgvimed), β2)

  #a = map(imi -> log.(i/imi)/β , imed)

  #d = cdf.(ln, a)
  d = cdf.(ln, Ref(ia))
  d2 = cdf.(ln2, Ref(iv))

  l = lines!.(ax, Ref(ia), d, linewidth = 1.8)
  #lines!.(ax, a, d)
  l2 = lines!.(ax2, Ref(iv), d2, linewidth = 1.8)

  Legend(f[1,3],
	l,
	["LS1","LS2","LS3"]
  )


  f

  save(string("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/fragility/", name, "-fragility.png"), f)
  

end
