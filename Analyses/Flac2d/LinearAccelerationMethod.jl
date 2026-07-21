using DelimitedFiles

#=
In the following function, the assumption is that the IM
and its Integral before the ground motion begins are both
equal to zero based on the Linear Acceleration Method
=#

function transform(IM::Vector{Float64}, dt::Float64)

  l = length(IM)
  integrated_IM::Vector{Float64} = [0.0] #[IM[1]*dt/2]
  for i = 2:l
  
    push!(integrated_IM, integrated_IM[i-1] + (IM[i] + IM[i-1])*dt/2)
    
  end

  return integrated_IM

end

function derivative(IM::Vector{Float64}, dt::Float64)

  l = length(IM)
  derived_IM::Vector{Float64} = [0.0] #[2IM[1]/dt]
  for i = 2:l

    push!(derived_IM, (IM[i] - IM[i-1])*2/dt - derived_IM[i-1])
    
  end

  return derived_IM

end

function loop_records!(inp::String, out::String)

  for record in readdir(inp)
    if endswith(record, ".txt")
      #println(record)
      i = match(r"\d+", record).match
      
      (acc, dt) = get_acc(record)
      vel = transform(acc, dt)
      #(his, PGIM, dt) = get_his(string(inp, record))
      wrt_his(record, vel, out)
    end
    println(record)

    
  end

  return nothing
end

function derive(path::String, record::String, out::String)
  
  i = match(r"\d+", record).match
  
  (vel, dt) = get_acc(record)
  vel = derivative(vel, dt)
  #(his, PGIM, dt) = get_his(string(inp, record))
  wrt_his(record, acc, out)
  
  return nothing
end

function get_acc(f)

  acc::Vector{Float64} = [];
  t = []
  
  for line in eachline(string(inp, f))
    l = line[4:end]
  
    l = replace(l, "   " => "  ")
    l = replace(l, "  " => ",")
    
    aci = parse(Float64, match(r",(.)+", l).match[2:end])
    push!(acc, aci)
    
    ti = parse(Float64, match(r"(.)+,", l).match[1:end-1])
    push!(t, ti)
    
  end

  dt = round(t[2]-t[1], sigdigits=2)
  
  if dt != round(t[2]-t[1], sigdigits=3)
    println(string("Warning: rounding in file ", f, " may be incorrect.\n Rounding with three significant digits would be:"))
    println(round(t[2]-t[1], sigdigits=3))
  end
  
  return acc, dt

end


function get_vel(inp, f)

  #vel::Vector{Float64} = [];
  #t = []
  
  l = collect(eachline(string(inp, f)))[5:end]
  
  l = replace.(l, "          "=>"")
  l = replace.(l, "   " => "  ")
  l = replace.(l, "  " => ",")
  vel = map(m -> parse(Float64, m.match[2:end]), match.(r",(.)+", l))
  #vei = parse(Float64, match(r",(.)+", l).match[2:end])
  #push!(vel, vei)
    
  #ti = parse(Float64, match(r"(.)+,", l).match[1:end-1])
  #push!(t, ti)
  t = map(m -> parse(Float64, m.match[1:end-1]), match.(r"(.)+,", l))

  dt = round(t[2]-t[1], sigdigits=2)
  
  if dt != round(t[2]-t[1], sigdigits=3)
    println(string("Warning: rounding in file ", f, " may be incorrect.\n Rounding with three significant digits would be:"))
    println(round(t[2]-t[1], sigdigits=3))
  end
  
  return vel, t, dt

end


function wrt_his(fl, vel, out)
  
  lines = collect(eachline(string(inp, fl)))
  
  for i = 1:length(lines)
  
    l = lines[i][4:end]
  
    l = replace(l, "   " => "  ")
    l = replace(l, "  " => ",")
    
    acs = match(r",(.)+", l).match[2:end]
    
    lines[i] = replace(lines[i], acs => vel[i])
 
  end
  
  writedlm(string(out, fl), lines, quotes=false)
  return nothing
  
end


#IM = "Vec"
#inp = "Input_clay_acc/Soil_Class_C/"
#out = "Input_clay_vel/Soil_Class_C/"

#loop_records!(inp, out)
