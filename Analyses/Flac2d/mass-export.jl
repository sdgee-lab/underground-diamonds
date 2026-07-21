using DataFrames
using CairoMakie
using GLM

include("result-edits.jl")
include("displacement.jl")
include("LinearAccelerationMethod.jl")
include("frag.jl")

#positions = ["KP2650/", "KP6250/", "KP8550/"]
#positions = ["KP2650/"]
#positions = ["KP6250/"]
positions = ["KP8550/"]

##=
suf = "_PGV/"
folders = string.([10, 20, 31, 35, 44, 49, 62, 76, 99, 106], suf)

paths = vcat(map(p -> string.(p, folders), positions)...)
lnδd::Vector{Float64} = []
lnPGA::Vector{Float64} = []
lnPGV::Vector{Float64} = []
#edp_names = ["KP2650", "KP6250", "KP8550"]

F = []

for path in paths
  r = readdir(path)
  d1 = deflection(path)
#  d2 = deflection2(path)
  
  ##=
  push!(lnδd, log(deflection(path)))
  gv = CSV.File(string(path, "ground_vel.csv"))
  push!(lnPGV, log(maximum(gv.Xvelocity)))
 # println("Path: ", maximum(gv.Xvelocity))
  
  ga = CSV.File(string(path, "ground_acc.csv"))
  push!(lnPGA, log(maximum(ga.Xacceleration)))
  # =#
  
  #=
  for file in r
    
    ##=
    if file == "ground_vel.txt"
      #println(path)
      
      (vel, t, dt) = get_vel(path, file)
      acc = derivative(vel, dt)
      
      global dfacc = DataFrame(t = t, Xacceleration = acc)
      CSV.write(string(path, "ground_acc.csv"), dfacc)
      println(path)
      println(file)
      println(maximum(dfacc.Xacceleration))
      
      
    end
    # =#
    if endswith(file, ".csv")
      
      if file == "0060_Xaccel_375_15.csv"
         #println(file)
 #         mv(string(path, file), string(path, "ground_acc", file[end-3:end]))
       # cacc = CSV.File(string(path, file))
        #dacc = DataFrame(t = cacc.t, Xacceleration = cacc.Xacceleration)
      #  println(cacc)
       #  println(string(path,file))
        #dfacc = DataFrame(t 
       # CSV.write(string(path, "ground_acc.csv"), dacc)
        
      elseif file =="0051_Xvel_501_5.csv"
  #      mv(string(path, file), string(path, "ground_vel", file[end-3:end]))
        cvel = CSV.File(string(path, file))
        dvel = DataFrame(t = cvel.t, Xvelocity=cvel.Xvelocity)
       # CSV.write(string(path, "ground_vel.csv"), dvel)
        #println(string(path, file))
        
        
        
        
      end
      
    end
    
    if endswith(file, ".txt")
      fp = string(path, file)
    
      lines = collect(eachline(fp))

      if length(findall(nothing .!= match.(r"History", lines))) > 1
        println("Warning: multiple \"History\" instances found in file")
      elseif isempty(lines)	
#        println(string("Skip: ", fp))
      else
        m = match(r"60_Xvel", file)
       # println(file)
        
        if !isnothing(m)
#          println(fp)
#          println(string(path, "ground_vel", file[end-)
#          mv(fp, string(path, "ground_vel", file[end-3:end]))

        end
#       	csv_export(fp)
       	#println(fp)
      
      end
    end
  end
  # =#
end
# =#

function edps(lnδd, lnPGA, lnPGV, edp_names)
  df = DataFrame(δ = lnδd, lnPGA = lnPGA, lnPGV = lnPGV)
  CSV.write(string(positions[1], "edp.csv"), df)
##=
  w = 420
  j = Figure(size = (1000, 500))
  ax = Axis(j[1,1], xlabel = L"\ln{PGA}", ylabel = L"\ln{δ_D/D}", xgridvisible = false, ygridvisible = false, width = w)
  ax2 = Axis(j[1,2], xlabel = L"\ln{PGV}", ylabel = L"\ln{δ_D/D}", xgridvisible = false, ygridvisible = false, width = w)
  global ols = lm(@formula(δ ~ lnPGA), df)
  global ols2 = lm(@formula(δ ~ lnPGV), df)

  d1 = extrema(predict(ols))
  d2 = extrema(predict(ols2))
  a = extrema(lnPGA)
  v = extrema(lnPGV)

  scatter!(ax, lnPGA, lnδd, color = :black)
  lines!(ax, [a[1], a[2]], [d1[1], d1[2]], color = :black, linestyle = :dash, linewidth = 2.0)

  rsq = round(r2(ols), digits=3)
  ci = coef(ols)
  c = round.(ci, digits=2)
  s = c[1] >= 0 ? "+" : "-"
  text!(ax, minimum(lnPGA), log(0.00281)-0.3, text = L"y=%$(c[2])x %$(s) %$(abs(c[1]))")
  text!(ax, minimum(lnPGA), log(0.00281)-0.4, text = L"$R^2$=%$(rsq)" )

  scatter!(ax2, lnPGV, lnδd, color = :black)
  lines!(ax2, [v[1], v[2]], [d2[1], d2[2]] , color = :black, linestyle = :dash, linewidth = 2.0)

  rsq2 = round(r2(ols2), digits=3)
  ci2 = coef(ols2)
  c2 = round.(ci2, digits=2)
  s2 = c[1] >= 0 ? "+" : "-"
  text!(ax2, minimum(lnPGV), log(0.00281)-0.3, text = L"y=%$(c2[2])x %$(s2) %$(abs(c2[1]))")
  text!(ax2, minimum(lnPGV), log(0.00281)-0.4, text = L"$R^2$=%$(rsq2)" )
  
  
  δd = log.([0.00281, 0.00312, 0.00362])
  h1 = hlines!.(ax, δd, linestyle = :dash)
  h2 = hlines!.(ax2, δd, linestyle = :dash)

  #j
  
  l = length(lnδd)
  χ1m = sum(lnPGA)/l
  x2m = sum(lnPGV)/l
  ym = sum(lnδd)/l

  βc = 0.3
  βds = 0.4
  
  βDa = deviance(ols)
  βDv = deviance(ols2)
  
  β1 = sqrt(βc^2 + βds^2 + βDa^2)
  β2 = sqrt(βc^2 + βds^2 + βDv^2)
  
  
  pgaimed = exp.((δd .- ci[1])./ci[2])
  pgvimed = exp.((δd .- ci2[1])./ci2[2])
  
  println(pgaimed)
  println(pgvimed)
  
  #fragility(pgaimed/10, pgvimed, β1, β2, edp_names)
  
 # save(string("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/fragility/", edp_names, "-PSDMs.png"), j)
  
# =#
end


