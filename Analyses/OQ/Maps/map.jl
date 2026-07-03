using GeoMakie, CairoMakie
using CSV
using GADM, DataFrames
import GeometryOps as GO

ass(x, y, i, prop) = getproperty(i, prop)[(1:x)*(1:y)']

inp_m = CSV.File("map_measured.csv")
inp_a = CSV.File("map_assigned.csv")

(x, y) = (inp_m.lon, inp_m.lat)

rt1_m = CSV.File("../line/route1_measured.csv")
rt1_a = CSV.File("../line/route1_assigned.csv")
rt1_vs_m = CSV.File("../line/output/line-vs-m/hazard_map-mean.csv")
rt1_vs_a = CSV.File("../line/output/line-vs-a/hazard_map-mean.csv")
rt1_sg_a = CSV.File("../line/output/line-sg-a/hazard_map-mean.csv")

res_vs_m = CSV.File("output/map-vs-m/hazard_map-mean.csv")
res_vs_a = CSV.File("output/map-vs-a/hazard_map-mean.csv")
res_sg_a = CSV.File("output/map-sg-a/hazard_map-mean.csv")

mac_df = GADM.get("GRC", "Macedonia and Thrace", "Central Macedonia"; depth = 1) |> DataFrame
gr_centroid = GO.centroid(mac_df.geom)
	
munic = ["Thessaloniki", "Kalamaria", "Ampelokipoi-Menemeni", "Neapoli-Sykies", "Pylaia-Chortiatis", "Pavlos Melas", "Kordelio-Evosmos", "Thermi", "Oraiokastro", "Delta", "Langadas"]

ind = map(m -> findfirst(mac_df.NAME_3 .== m), munic)
#the = findfirst(mac_df .== "Thessaloniki")


input_files = [inp_m, inp_a, res_vs_m, res_vs_a, res_sg_a]; input_routes = [rt1_m, rt1_a, rt1_vs_m, rt1_vs_a, rt1_sg_a]; outputs = ["measured_vs", "assigned_vs", "measured_PGA", "assigned_PGA", "slope_PGA", "measured_PGV", "assigned_PGV", "slope_PGV"] 

#=
input_files = [inp_m, res_vs_m]
input_routes = [rt1_m, rt1_vs_m]
outputs = ["measured_vs", "measured_PGA", "measured_PGV"]
=#

#input_files = [inp_m]; input_routes = [rt1_m]; outputs = ["measured_vs"]


#for i in input_files

xi = range(extrema(x)..., n)
yi = range(extrema(y)..., n)


for len = 1:length(input_files)

	i = input_files[len]
	rt = input_routes[len]

	local n = 22
		
#	nx = 45
#	ny = 45
		
#	vs_mat = map(Float64, inp_m.vs30[i*j] for i=1:n, j=1:n)

	local f = Figure(size = (500, 500))
	local ga = GeoAxis(
		f[1, 1];	
		dest = "+proj=ortho +lon_0=$(gr_centroid[1]) +lat_0=$(gr_centroid[2])",
#		title = L"$V_{s30}$ Map",
		subtitle = "Line 1, Route 1, Thessaloniki Metro",
		aspect = .7,
		)
	xlims!(ga, 22.9, 23)
	ylims!(ga, 40.57, 40.66)
	hidedecorations!(ga)
	
	local f2 = Figure(size = (500, 500))
	ga2 = GeoAxis(
		f2[1, 1];
		dest = "+proj=ortho +lon_0=$(gr_centroid[1]) +lat_0=$(gr_centroid[2])",
#		title = L"$V_{s30}$ Map",
		subtitle = "Line 1, Route 1, Thessaloniki Metro",
		aspect = .7,
		)
	xlims!(ga2, 22.9, 23)
	ylims!(ga2, 40.57, 40.66)
	
	hidedecorations!(ga2)

	if length(i[1]) ==3
		ga.title[] = L"$V_{s30}$ Map"
		cmap = :viridis
		
		# Should have used reshape instead of the custom ass
		z = reshape(getproperty(i, :vs30), n, n) #ass(n, n, i, :vs30)
		c = contourf!(ga, xi, yi, z, extendhigh = :auto, extendlow = :auto)
		#c = surface!(ga, xi, yi, z, shading = NoShading)
		symb = :vs30
		cr = extrema(vcat(getproperty(i, symb), getproperty(rt, symb)))
		units = L"$V_{s30}\;(m/sec)$"

	elseif length(i[1])==8
		if i.names[3] == :slope
			ga.title[] = L"$V_{s30}$ Map"
			z = reshape(getproperty(i, :vs30), n, n)#ass(n, n, i, :vs30)
			c = contourf!(ga, xi, yi, z, extendhigh = :auto, extendlow = :auto)
			#c = surface!(ga, xi, yi, z, shading = NoShading)#, color = cmap)
			symb = :vs30
			cr = extrema(vcat(getproperty(i, symb), getproperty(rt, symb)))
			units = L"$V_{s30}\;(m/sec)$"
			
		else
			cmap = :amp
			z = nothing
			ga.title[] = "Mean PGA for 2500 years"
			z = reshape(getproperty(i, :var"PGA-0.0004"), n, n)#ass(n, n, i, :var"PGA-0.0004")
			symb =  Symbol("PGA-0.0004")
			#c = surface!(ga, xi, yi, z, shading = NoShading)#, color = cmap)
			c = contourf!(ga, xi, yi, z, extendhigh = :auto, extendlow = :auto, colormap = :amp)
			cr = extrema(vcat(getproperty(i, symb), getproperty(rt, symb)))
			
			ga2.title[] = "Mean PGV for 2500 years"
			z_v = reshape(getproperty(i, :var"PGV-0.0004"), n, n)#ass(n, n, i, :var"PGV-0.0004")
			#c2 = surface!(ga2, xi, yi, z_v, shading = NoShading)#, colormap = cmap)
			c2 = contourf!(ga2, xi, yi, z_v, extendhigh = :auto, extendlow = :auto, colormap = :amp)
			symb2 =  Symbol("PGV-0.0004")
			cr2 = extrema(vcat(getproperty(i, symb2), getproperty(rt, symb2)))
			
			units = L"$PGA\;(g)$"
			units2 = L"$PGV\;(cm/sec)$"

	


		end
	end
	
	#poly!(ga, [22.9, 23., 23., 22.9, 22.9], [40.56, 40.56, 40.7, 40.7, 40.56], color = :cyan)
	#poly!(ga2, [22.9, 23., 23., 22.9, 22.9], [40.56, 40.56, 40.7, 40.7, 40.56], color = :cyan)


	#translate!(c, 0, 0, maximum(z |> skipmissing))
	#translate!(c2, 0, 0, maximum(z_v |> skipmissing))
	

	poly!(
	    ga, mac_df.geom[ind];
#	    color = :beige,
	    color = :transparent,
	    #color = 1:size(ind, 1),
	    #color = 1:size(mac_df, 1),
	    strokecolor = :black, strokewidth = .8, shading = NoShading,
#	    alpha = .1,
#	    transparency = true,
	    visible = true
	    )

	    l = lines!(ga, rt.lon, rt.lat, linewidth = 2.4, color = :black, alpha = 0.7) #getproperty(rt, symb), colorrange = cr, colormap = cmap)


	Colorbar(f[1,2], c, label = units)
	

#	heatmap!(ga, xi, yi, rand(22, 22))
	name = outputs[len]
	#m = match(r"\w+.csv", string(i))
	#name = m.match[1:end-4]
	save(string("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/Map_", name, ".png"), f)
#	save(string("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/", name, ".png"), f)
#	save(string("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/", name, ".png"), f)
 	
	f


	if i.names[3] == Symbol("PGV-0.0004")
		
		poly!(
		    ga2, mac_df.geom[ind];
	#	    color = :beige,
		    color = :transparent,
		    #color = 1:size(ind, 1),
		    #color = 1:size(mac_df, 1),
		    strokecolor = :black, strokewidth = .8, shading = NoShading,
	#	    alpha = .1,
	#	    transparency = true,
		    visible = true
		    )

		    l2 = lines!(ga2, rt.lon, rt.lat, linewidth = 2.4, color = :black, alpha = 0.7)# getproperty(rt, symb2), colorrange = (1, 10), colormap = cmap)
		
		Colorbar(f2[1,2], c2, label = units2)

		name2 = outputs[len+3]
#		name2 = outputs[len+1]

		save(string("/home/hootseer/Documents/underground-diamonds/LaTeX/figures/hazard/Map_", name2, ".png"), f2)
	
	
	
	end
	
end


#inp_m.vs30



#c = contourf!(ga, inp_m.lon, inp_m.lat, inp_m.vs30, extendhigh = :auto, extendlow = :auto, )



#=


g= Figure()
axx = Axis(g[1,1])
xi = vcat(map(i -> 1:2, 1:2)...) #range(22.9, 23, 100)
yi = Int.(map(i -> round(i/2, RoundUp), 1:4)) #range(40.57, 40.66, 100)

ran_v = rand(4)

c = contourf!(axx, xi, yi, ran_v)

Colorbar(f[1,2], c)
g
=#

