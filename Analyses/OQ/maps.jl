include("inter.jl")

rt1 = CSV.File("Full_Line-1_Route-1.csv")

#lon = extrema(rt1.lon)
#lat = extrema(rt1.lat)

lon = (22.9, 23)
lat = (40.57, 40.66)

n = 22

up = 1.0001
down = 0.9999

x = range(lon[1]*down, lon[2]*up, n)
y = range(lat[1]*down, lat[2]*up, n)

map(i -> x[i], 1:n)

cords = vcat(map(j -> map(i -> (x[i], y[j]), 1:n), 1:n)...)

map_df = DataFrame(lon = map(c -> c[1], cords), lat = map(c -> c[2], cords))

CSV.write("Maps/map.csv", map_df)
map_csv = CSV.File("Maps/map.csv")

map_int = assign_velocity(inp, micro, map_csv, "Maps/", false, "map_measured.csv")
