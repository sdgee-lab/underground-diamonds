using GeoStats
using DataFrames
#using CairoMakie

include("merc-transform.jl")

inp = "/media/hootseer/Windows-SSD/Users/hatzh/Documents/Notes/Geotechnical Wiki/Διπλωματική/data/"

micro = CSV.File("1d_sites_cen2_metro.csv")
#micro2 = CSV.File("1d_sites_cen2_metro.csv")

#=
cd(inp)

rt1 = CSV.File("line1_route1.csv")
rt2 = CSV.File("line1_route2.csv")

micro = CSV.File("1d_sites_cen2_metro.csv")

(x1, y1) = merc(rt1.lon, rt1.lat)

(xm, ym) = merc(micro.POINT_X, micro.POINT_Y)

pm = Point.(xm, ym, )

intm = georef((v=micro.Vs30_1,), pm)

P = PointSet(Point.(x1, y1))

model = Kriging(GaussianVariogram(range=35.))

intrp = intm |> Interpolate(P, model=model)

df = DataFrame(lon = rt1.lon, lat = rt1.lat, vs30 = intrp.v)

=#

#int = assign_velocity(inp, micro, "line1_route1", "line/")
#rt1 = CSV.File("Full_Line-1_Route-1.csv")
#int = assign_velocity(inp, micro, rt1, "line/")
#int = assign_velocity(inp, micro, rt1, "line/", false)


function assign_velocity(dir::String, calc::CSV.File, inp::CSV.File, output::String, densify::Bool, file_name::String = "route1_measured.csv")
  
#  cd(dir)

#  cords =  CSV.File(string(inp, ".csv"))
  
  lla = LLA.(inp.lat, inp.lon)
  cords = ECEFfromLLA(wgs84).(lla)
  arg_cords = map(i -> map(c -> c[i], cords), 1:3)
  
  if densify
  l_cords = (l_x, l_y, l_z) = int_length((arg_cords...), linearize(arg_cords...), 500)
  #arg_l_cords = map(i -> map(c -> c[i], l_cords), 1:3)
  else
    l_cords = (l_x, l_y, l_z) = arg_cords
  end
  
  l_lla = LLAfromECEF(wgs84).(ECEF.(l_x, l_y, l_z))
  
  P = PointSet(GeoStats.Point.(l_cords...))

  m_lla = LLA.(calc.POINT_Y, calc.POINT_X)
  
  m_cords = ECEFfromLLA(wgs84).(m_lla)
  arg_m_cords = map(i -> map(c -> c[i], m_cords), 1:3)
  pm = GeoStats.Point.(arg_m_cords...)
  
  intm = georef((vs30=calc.Vs30_1,), pm)
  
  model = Kriging(ExponentialVariogram(range=8000.0), 340)
  
  intrp = intm |> Interpolate(P	, model=model)
  
  pol_cords = inv
  
  (lat, lon) = (map(l -> l.lat, l_lla), map(l -> l.lon, l_lla))
  
  df = DataFrame(lon = lon, lat = lat, vs30 = intrp.vs30)
  
  CSV.write(string(output, file_name), df)

  return intrp

end


function assign_velocity(dir::String, calc::CSV.File, inp::String, output::String)
  
  cd(dir)

  cords =  CSV.File(string(inp, ".csv"))

  (x, y) = merc(cords.lon, cords.lat)
  P = PointSet(Point.(x, y))

  (xm, ym) = merc(calc.POINT_X, calc.POINT_Y)
  pm = Point.(xm, ym,)
  
  intm = georef((vs30=calc.Vs30_1,), pm)
  
  model = Kriging(GaussianVariogram(range=200.))
  
  intrp = intm |> Interpolate(P, model=model)
  
  df = DataFrame(lon = cords.lon, lat = cords.lat, vs30 = intrp.vs30)
  
  CSV.write(string(output, inp, "_calculated.csv"), df)

  return nothing

end


