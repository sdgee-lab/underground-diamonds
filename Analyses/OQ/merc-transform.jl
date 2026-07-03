using CSV
using Interpolations
using Geodesy

function merc(θ::Float64, λ::Float64, a::Float64=6378137.0, b::Float64=6356752.3)

  μ = atanh(b/a)
  A = a/cosh(μ)
 
#  xe = A*cosh(μ)*cos(λ)*cos(θ)
#  ye = A*cosh(μ)*cos(λ)*sin(θ)
  xp = a*θ*pi/180
  yp = z = A*sinh(μ)*sin(λ*pi/180)
  
  return xp, yp

end

function merc(θ::Vector{Float64}, λ::Vector{Float64}, a::Float64=6378137.0, b::Float64=6356752.3)
  # θ = lon
  # λ = lat
  μ = atanh(b/a)
  A = a/cosh(μ)
 
  xp = a*θ*pi/180
  yp = z = A*sinh(μ)*sin.(λ*pi/180)
  
  return xp, yp

end

function inv_merc(xp::Vector{Float64}, yp::Vector{Float64}, a::Float64=6378137.0, b::Float64=6356752.3)

  μ = atanh(b/a)
  A = a/cosh(μ)

  θ = (xp/a)*180/pi
  λ = asin.(yp/(A*sinh(μ)))*180/pi
  
  return θ, λ

end

function resize(x::Vector{Float64}, y::Vector{Float64}, fix::Tuple{Float64, Float64}, s::Tuple{Float64, Float64}, e::Tuple{Float64, Float64})

  Δx = s[1] - fix[1]
  ΔX = e[1] - fix[1]
  
  Δy = s[2] - fix[2]
  ΔY = e[2] - fix[2]
  
  if Δx != 0 && Δy !=0
  
    rx = abs(ΔX/Δx)
    ry = abs(ΔY/Δy)

    xi = fix[1] .+ (x .- fix[1])*rx
    yi = fix[2] .+ (y .- fix[2])*ry 
  
  else
    xi =0
    yi = 0
    print("Fails")
  end  
  
  return xi, yi

end

function resize(x::Vector{Float64}, y::Vector{Float64}, s::Tuple{Float64, Float64}, e::Tuple{Float64, Float64})
  # Top left stays still, everything else moves
  # If the moving point concides with the horizontal and vertical lines
  # of the top left point, the resizing will fail
  (xmin, xmax) = extrema(x)
  (ymin, ymax) = extrema(y)

  Δx = s[1] - xmin
  ΔX = e[1] - xmin
  
  Δy = ymax - s[2]
  ΔY = ymax - e[2]
  
  if Δx != 0 && Δy !=0
  
    rx = ΔX/Δx
    ry = ΔY/Δy

    xi = xmin .+ (x .- xmin)*rx
    yi = ymax .-(ymax .-y)*ry 
  
  else
    xi =0
    yi = 0
    print("Fails")
  end  
  
  return xi, yi

end

function el_coo(λ::Float64, φ::Float64, a::Float64=6378137.0, b::Float64=6356752.3)
  # λ = lon, φ = lat
  sinφ, cosφ = sincosd(φ)
  sinλ, cosλ = sincosd(λ)

  e2 = (1 - b^2/a^2)
  N = a/sqrt(1 - e2*sinφ^2)
  
  x = N*cosφ*cosλ
  y = N*cosφ*sinλ
  z = (1-e2)*N*sinφ

  return x, y, z

end

function el_coo(λ::Vector{Float64}, φ::Vector{Float64}, a::Float64=6378137.0, b::Float64=6356752.3)
  # λ = lon, φ = lat
  sinφ, cosφ = sin.(φ*pi/180), cos.(φ*pi/180)
  sinλ, cosλ = sin.(λ*pi/180), cos.(λ*pi/180)

  e2 = 1 - b^2/a^2
  N = a./sqrt.(1 .- e2*sinφ.^2)
  
  x = N.*cosφ.*cosλ
  y = N.*cosφ.*sinλ
  z = (1-e2)*N.*sinφ
  
  return x, y, z

end

function cart_to_polar(x::Vector{Float64}, y::Vector{Float64}, z::Vector{Float64})
  
end

function get_z(x::Float64, y::Float64, a::Float64=6378137.0, b::Float64=6356752.3)
  
  z = b*sqrt(1 - (x^2 + y^2)/a^2)
  
  return z

end

function linearize(x::Vector{Float64}, y::Vector{Float64}, z::Vector{Float64})

  Δx = x[2:end] .- x[1:end-1]
  Δy = y[2:end] .- y[1:end-1]
  Δz = z[2:end] .- z[1:end-1]
  l = sqrt.(Δx.^2 .+ Δy.^2 .+ Δz.^2)
  L = sum(l)
  xi = vcat(0.0, map(i -> sum(l[1:i]), 1:length(l)))
  
  return xi

end

function linearize(x::Vector{Float64}, y::Vector{Float64})

  Δx = x[2:end] .- x[1:end-1]
  Δy = y[2:end] .- y[1:end-1]
  l = sqrt.(Δx.^2 .+ Δy.^2)
  L = sum(l)
  xi = vcat(0.0, map(i -> sum(l[1:i]), 1:length(l)))
  
  return xi

end

function int_length(x::Vector{Float64}, y::Vector{Float64}, z::Vector{Float64}, l::Vector{Float64}, range::Int64)

  inter_x = linear_interpolation(l, x)
  inter_y = linear_interpolation(l, y)
  inter_z = linear_interpolation(l, z)
  
  l_in = LinRange(l[1], l[end], range)

  x_in = inter_x.(l_in)
  y_in = inter_y.(l_in)
  z_in = inter_z.(l_in)

  return [x_in, y_in, z_in]

end

function int_length(x::Vector{Float64}, y::Vector{Float64}, l::Vector{Float64}, range::Int64)

  inter_x = linear_interpolation(l, x)
  inter_y = linear_interpolation(l, y)
  
  l_in = LinRange(l[1], l[end], range)

  x_in = inter_x.(l_in)
  y_in = inter_y.(l_in)

  return [x_in, y_in]

end

