using DelimitedFiles

#=
his[1] = "Vel\tLefkada_X_ACC_010g_cms2.ac"
his[2] = "3000 0.01"
his[3:end] = acc

Vel depends on the function, either Vel or Acc
afterwards comes the name
\t and .ac are standard

3000 is length(acc) and is the number of steps
0.01 would be dt, calculated easily by t[2]-t[1]
=#

# Initialize Variables
#=
# Acceleration Time Histories
IM = "Acc"
inp = "Input_clay_acc/Soil_Class_C/"
out = string("Time-Histories/", IM, inp[end-2:end])
=#

# #=
# Velocity Time Histories
IM = "Vel"
inp = "Input_clay_vel/Soil_Class_C/"
out = string("Time-Histories/", IM, inp[end-2:end])
# =#

Peak_IMs = []
indices = []
files = []



# Initialize Functions
function loop_records!(PGs::Vector, ind::Vector, fl::Vector)

  for record in readdir(inp)
    if endswith(record, ".txt")
      #println(record)
      i = match(r"\d+", record).match
      

      (his, PGIM, dt, l) = get_his(string(inp, record))

      pushfirst!(his, string(l, " ", dt))
      pushfirst!(his, string(IM, "\t", record, ".ac"))
        
      push!(PGs, PGIM)
      push!(ind, i)
      push!(fl, his)
    end
  end
  
  return nothing

end


function get_his(f)
  t = [];
  acc = [];

  data = []
  for line in eachline(f)
    l = line[4:end]
  
    l = replace(l, "   " => "  ")
    l = replace(l, "  " => ", ")
  
    push!(data, l)
    
  end

  m1 = match.(r"(.+),", data)
  tm = map(mi -> mi.match[1:end-1], m1)
  t = parse.(Float64, tm)

  m2 = match.(r",(.+)", data)
  IMm = map(mi -> mi.match[2:end], m2)
  IM = parse.(Float64, IMm)
  
  max_IM = maximum(abs.(IM))
  dt = round(t[2]-t[1], sigdigits=2)
  
  if dt != round(t[2]-t[1], sigdigits=3)
    println(string("Warning: rounding in file ", f, " may be incorrect.\n Rounding with three significant digits would be:"))
    println(round(t[2]-t[1], sigdigits=3))
  end
  
  l = length(IM)
  
  return IMm, max_IM, dt, l

end

# Export files

loop_records!(Peak_IMs, indices, files)

#dic = Dict(zip(Peak_IMs, indices))
#dic = sort(collect(dic), by=x->x[1])
nam = Int64.(round.(Peak_IMs))

if IM == "Acc"
  kat = "_PGA.his"
elseif IM == "Vel"
  kat = "_PGV.his"
end
writedlm.(string.(out, nam, kat), files, quotes=false)

