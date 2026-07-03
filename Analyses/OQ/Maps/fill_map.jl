using CSV
using DataFrames

map_m = CSV.File("map.csv")
map_a = CSV.File("old_new_map_assigned.csv")
#map_a = CSV.File("output/map-sg-a/old_hazard_map-mean.csv")

#output = "output/map-sg-a/hazard_map-mean.csv"

df_m = DataFrame(map_m)
df_a = DataFrame(map_a)


(lon, lat) = (map_m.lon, map_m.lat)

ind = map(a -> findfirst(ceil.(map_m.lon, digits=3) .== ceil(a.lon, digits=3) .&& ceil.(map_m.lat, digits=3) .== ceil(a.lat, digits=3)), map_a)

l = length(map_m)

#insertcols.(df_m, map_a.names => zeros(l))

typ = map_a.types[3:end]
map(i -> insertcols!(df_m, i => zeros(l)), map_a.names[3:end])
#insertcols!(df_m, map_a.names[5] => fill(String31("UNKNOWN"), l))
#map(i -> insertcols!(df_m, i => zeros(l)), map_a.names[6:end])
map(i -> getproperty(df_m, i)[ind] .= getproperty(map_a, i), map_a.names[3:end])

CSV.write(output, df_m)
