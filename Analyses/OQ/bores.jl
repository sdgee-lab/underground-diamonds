using GeoMakie, CairoMakie
using CSV
using GADM, DataFrames
import GeometryOps as GO

mac_df = GADM.get("GRC", "Macedonia and Thrace", "Central Macedonia"; depth = 1) |> DataFrame
gr_centroid = GO.centroid(mac_df.geom)

f = Figure(size = (500, 500))
ga = GeoAxis(
	f[1, 1];
	dest = "+proj=ortho +lon_0=$(gr_centroid[1]) +lat_0=$(gr_centroid[2])",
	title = "Available Boreholes",
	subtitle = "Line 1, Route 1, Thessaloniki Metro",
	aspect = .7,
	)
xlims!(ga, 22.9, 23)
ylims!(ga, 40.57, 40.66)

poly!(ga, [22.9, 23., 23., 22.9, 22.9], [40.56, 40.56, 40.7, 40.7, 40.56], color = :cyan)

hidedecorations!(ga)

munic = ["Thessaloniki", "Kalamaria", "Ampelokipoi-Menemeni", "Neapoli-Sykies", "Pylaia-Chortiatis", "Pavlos Melas", "Kordelio-Evosmos", "Thermi", "Oraiokastro", "Delta", "Langadas"]

ind = map(m -> findfirst(mac_df.NAME_3 .== m), munic)
#the = findfirst(mac_df .== "Thessaloniki")

poly!(
    ga, mac_df.geom[ind];
    color = :beige,
    #color = 1:size(ind, 1),
    #color = 1:size(mac_df, 1),
    strokecolor = :black, strokewidth = .8, shading = NoShading
    )
    
rt1 = CSV.File("Full_Line-1_Route-1.csv")
lines!(ga, rt1.lon, rt1.lat, color = :red, linewidth = 2.4)


micro = CSV.File("1d_sites_cen2_metro.csv")

(x, y) = (micro.POINT_X, micro.POINT_Y)
sc = scatter!(ga, x, y, color = micro.Vs30_1)
cb = Colorbar(f[1, 2], sc, label = L"$V_{s30}$", size = 15, labelsize = 22)#, color = range(extrema(micro.Vs30_1, 7))

colsize!(f.layout, 1, Aspect(1, .9))

save("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/boreholes.png", f)
