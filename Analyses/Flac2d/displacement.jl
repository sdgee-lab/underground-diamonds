using CSV

function deflection(inp::String)

  D = 6
  x1 = CSV.File(string(inp, "x_1.csv"))
  x2 = CSV.File(string(inp, "x_2.csv"))
  y1 = CSV.File(string(inp, "y_1.csv"))
  y2 = CSV.File(string(inp, "y_2.csv"))

  Δx = x2.Xdisplacement - x1.Xdisplacement
  Δy = y2.Ydisplacement - y1.Ydisplacement

  xi = D/sqrt(2) .+ Δx
  yi = D/sqrt(2) .+ Δy

  d = sqrt.(xi.^2 + yi.^2)

  δd = d .-D
  
  maxδd = maximum(abs.(δd))/D

  return maxδd

end


function deflection2(inp::String)

  D = 6
  x1 = CSV.File(string(inp, "x_3.csv"))
  x2 = CSV.File(string(inp, "x_4.csv"))
  y1 = CSV.File(string(inp, "y_3.csv"))
  y2 = CSV.File(string(inp, "y_4.csv"))

  Δx = x2.Xdisplacement - x1.Xdisplacement
  Δy = y2.Ydisplacement - y1.Ydisplacement

  xi = D/sqrt(2) .+ Δx
  yi = D/sqrt(2) .+ Δy

  d = sqrt.(xi.^2 + yi.^2)

  δd = d .-D
  
  
  maxδd = maximum(δd)

  return maxδd

end

function flexibility(Es::Float64, vs::Float64)
  
  F = Es*(1-vs^2)*3^3/(6*30000*0.00225*(1+.2))
  
  return F
  
end
# #=
Es = [527., 459., 534.]
vs = [.32, .35, .34]
F = flexibility.(Es, vs)
# =#
