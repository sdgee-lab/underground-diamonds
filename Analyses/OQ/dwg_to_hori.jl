using GLMakie
using GeoStats
using DataFrames
#import CoordRefSystems as CRS

include("merc-transform.jl")

f = Figure()
ax = Axis(f[1, 1], aspect = DataAspect())

#inp = "/media/hootseer/Windows-SSD/Users/hatzh/Documents/Notes/Geotechnical Wiki/Διπλωματική/data/"

rt1 = CSV.File("drawings/route1.csv")
rt1_old = CSV.File("line1_route1.csv")
#rt2 = CSV.File("drawings/route2.csv")

lla = LLA.(rt1_old.lat, rt1_old.lon)

cords = ECEFfromLLA(wgs84).(lla)
arg_cords = map(i -> map(c -> c[i], cords), 1:3)

L = linearize(arg_cords...)
f_L = findfirst(x -> x>2000, L)
lla_L = LLAfromECEF(wgs84)(cords[f_L])

# Kalamaria overdrive old: 165, dwg: 1400
# Before Γ overdrive old: 125, dwg: 1030
#n1 = 125
n1 = 906
#m1 = 1030
m1 = 635
n2 = 1170
m2 = 950

m = merc(rt1_old.lon, rt1_old.lat)
m = int_length(m..., linearize(m...), 2000)


X = rt1.X
Y = rt1.Y

X, Y = int_length(X, Y, linearize(X, Y), 2000)

X .+= -X[m1] + m[1][n1]
Y .+= -Y[m1] + m[2][n1]


l = linearize(X, Y)
l_m = linearize(m...)

#s = (1647.5371 + m[1][n2], -1132.9734 + m[2][n2])
#s = (X[m2], Y[m2])
#ind = findfirst(x -> x>2000, linearize(m...))

ni = 1700
s = (X[ni] , Y[ni])
(xi, yi) = (X[ni:end] .- X[ni] .+ m[1][end], Y[ni:end] .- Y[ni] .+ m[2][end]) 
(xi, yi) = resize(xi, yi, (xi[1], yi[1]), (xi[end], yi[end]), (xi[end] + 30, yi[end] + 430))
X_end = vcat(m[1], xi)
Y_end = vcat(m[2], yi)

l_end = linearize(X_end, Y_end)
(X_end, Y_end) = int_length(X_end, Y_end, l_end, 400)

lnlt = inv_merc(X_end, Y_end)

ll_dwg = LLA.(lnlt[2], lnlt[1])
cords_dwg = ECEFfromLLA(wgs84).(ll_dwg)
arg_dwg = map(i -> map(c -> c[i], cords_dwg), 1:3)

#print(linearize(arg_dwg...)[end])
#=
L = linearize(arg_dwg...)
arg_dwg = int_length(arg_dwg..., L, 300)
cords_dwg = ECEF.(arg_dwg...)
ll_dwg = LLAfromECEF(wgs84).(cords_dwg)
ll_list = map(i ->
=#

df = DataFrame(lon = lnlt[1], lat = lnlt[2])
CSV.write("Full_Line-1_Route-1.csv", df)

g = Figure()
axx = Axis(g[1,1], aspect = DataAspect())

scatter!(axx, X, Y)
scatter!(axx, m...)
scatter!(axx, xi, yi)

#mrc = Mercator.(


#z = get_z.(rt1.X, rt1.Y)
#l = linearize(rt1.X, rt1.Y)






ec = ECEF.(rt1.X, rt1.Y, rt1.Z)


#=
X = rt1.X .+ arg_cords[1][1]
Y = rt1.Y .+ arg_cords[2][1]
Z = get_z.(X, Y)
=#

#julia> map(i -> round.(inv_merc(m...)[i], digits=6), 1:2)



#lines!(ax, rt1.X, rt1.Y)
lines!(ax, X, Y)
lines!(ax, arg_cords[1], arg_cords[2])
#lines!(ax, rt2.X, rt2.Y)

#=
j = Figure()
axj = Axis3(j[1,1])#, aspect=DataAspect())

lines!(axj, X, Y, Z)
lines!(axj, arg_cords...)
=#


