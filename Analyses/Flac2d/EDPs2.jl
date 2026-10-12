using CairoMakie
using CSV
using FFTW
using Interpolations

include("displacement.jl")
include("LinearAccelerationMethod.jl")

fp = string.("KP", [2650, 6250, 8550])

##=
wd = collect.(walkdir.(fp))
resf = map(wi -> map(wia -> string.(wia[1], "/"), wi[2:end]), wd)
#ind = map(i -> i, ind)
#resf = string
files = map(r -> readdir.(r), resf)
pgvs = [8, 25, 87]
folders = map(fol -> string.(fol, "/", pgvs, "_PGV/"), fp)

#δ = map(r -> deflection.(r), resf)
δ = map(r -> deflection_th.(r), folders)
Mf = map(f -> CSV.File.(string.(f, "m_1.csv")), folders)
M = map(Mfi -> map(m -> m.Moment1 ./1000, Mfi), Mf)
r = collect.(eachline.(map(p -> string("Time-Histories/Vel_C/", p, "_PGV.his"), pgvs)))
#map(ri -> match(r"\d(.)+", ri[1]).match, r)
rn = map(ri -> match(r"\d\d", ri[1]).match, r)
	

c = collect.(eachline.(string.("Input_clay_acc/Soil_Class_C/", rn, "_record.txt")))
t_itp = map(c -> map(c -> parse.(Float64, match(r"(.)+\d ", c).match), c), c)
acc_itp = map(cj -> map(ci -> parse.(Float64, match(r"\d (.)+", ci).match[2:end]), cj), c)
itp = map((a, t) -> linear_interpolation(t, a, extrapolation_bc=Line()), acc_itp, t_itp)

t = map(Mfi -> map(m -> m.t, Mfi), Mf)
T = map(i -> map(j -> t[i][j][2] - t[i][j][1], 1:3), 1:3)
#freqs = map((ti, Ti) -> fftshift.(fftfreq.(length.(ti), 1/Ti)), t, T)	
freqs = map(i -> map(j -> fftshift(fftfreq(length(t[i][j]), 1/T[i][j])), 1:3), 1:3)

# =#

#=
basef = map(f -> CSV.File.(string.(f, "base.csv")), folders)
topf = map(f -> CSV.File.(string.(f, "PGV.csv")), folders)
base_f = map(Bfi -> map(b -> abs.(fftshift(fft(b.Xvelocity))), Bfi), basef)
top_f = map(Tfi -> map(t -> abs.(fftshift(fft(t.Xvelocity))), Tfi), topf)
#tf = map((Bfi, Tfi) -> map((b, t) -> abs.(fftshift(fft(t.Xvelocity))) ./abs.(fftshift(fft(b.Xvelocity))), Bfi, Tfi), basef, topf)
rat = map((Bfi, Tfi) -> map((b, t) -> t ./b, Bfi, Tfi), base_f, top_f)
=#
top_v = map(f -> CSV.File.(string.(f, "PGV.csv")), folders)
base_v = map(f -> CSV.File.(string.(f, "base.csv")), folders)
top_a = map(f -> CSV.File.(string.(f, "PGA.csv")), folders)
dt = T #map(t -> map(ti -> ti.t[2] - ti.t[1], t), top_a)
#itp = linear_interpolation(
#base_a = map(j -> map(i -> derivative(base_v[j][i].Xvelocity, dt[j][i]), 1:3), 1:3)
#base_a = map(i -> itp[i](t_itp[i]), 1:3)
base_a = map(j -> map(i -> itp[i](t[j][i]), 1:3), 1:3)
#base_f = map(Bfi -> map(b -> abs.(fftshift(fft(b.Xvelocity))), Bfi), base_a)
#top_f = map(Tfi -> map(t -> abs.(fftshift(fft(t.Xvelocity))), Tfi), top_a)
base_f = map(Bfi -> map(b -> abs.(fftshift(fft(b ./100))), Bfi), base_a)
top_f = map(Tfi -> map(t -> abs.(fftshift(fft(t.Xacceleration))), Tfi), top_a)

#tf = map((Bfi, Tfi) -> map((b, t) -> abs.(fftshift(fft(t.Xvelocity))) ./abs.(fftshift(fft(b.Xvelocity))), Bfi, Tfi), basef, topf)
rat = map((Bfi, Tfi) -> map((b, t) -> t ./b, Bfi, Tfi), base_f, top_f)


# =#
#t = t
#acc
#vel

f = map(i -> Figure(), 1:3)
f_th = map(i -> Figure(size=(1000,400)), 1:3)
f_tf = map(i -> Figure(), 1:3)

#=
ax = map(f -> map(i -> Axis(f[i,1], xgridvisible=false, ygridvisible=false, xlabel= L"Time ($sec$)", ylabel= L"Diametric Deflection $\delta_d$"), 1:3), f)
ax2 = map(f -> map(i -> Axis(f[i,2], xgridvisible=false, ygridvisible=false, xlabel= L"Time ($sec$)", ylabel= L"Bending Moment $M$"), 1:3), f)
=#
xlabs = ["", "", L"Time ($sec$)"]
xlabs_tf = ["", "", L"Frequency ($Hz$)"]
#ylabs
ax = map(f -> map(i -> Axis(f[i,1], xgridvisible=false, ygridvisible=false, xlabel = xlabs[i], ylabel = L"\delta_D ($m$)"), 1:3), f)
ax2 = map(f -> map(i -> Axis(f[i,2], xgridvisible=false, ygridvisible=false, xlabel = xlabs[i], ylabel = L"M ($kNm/m$)"), 1:3), f)

#=
ax_th = map(f -> map(i -> Axis(f[i,1], xgridvisible=false, ygridvisible=false, xlabel = xlabs[i], ylabel = L"\dot{u} ($m/sec$)"), 1:3), f_th)
ax2_th = map(f -> map(i -> Axis(f[i,2], xgridvisible=false, ygridvisible=false, xlabel = xlabs[i], ylabel = L"\ddot{u} ($m/sec^2$)"), 1:3), f_th)
=#

w = 400
ax_th = map(f -> Axis(f[1,1], xgridvisible=false, ygridvisible=false, xlabel = L"Time ($sec$)", ylabel = L"\dot{u} ($cm/sec$)", width = w, title = "Velocity Input"), f_th)
ax2_th = map(f -> Axis(f[1,2], xgridvisible=false, ygridvisible=false, xlabel = L"Time ($sec$)", ylabel = L"\ddot{u} ($g$)", width = w, title = "Acceleration Input"), f_th)

#ax_tf = map(f -> map(i -> Axis(f[i,1], xgridvisible=false, ygridvisible=false, xlabel = xlabs_tf[i], limits = ((0.5, 14), (0, 30))), 1:3), f_tf)
#ax_tf = map(f -> map(i -> Axis(f[i,1], xgridvisible=false, ygridvisible=false, xlabel = xlabs_tf[i], ylabel = L"Amplitude", limits = ((0.5, 14), nothing)), 1:3), f_tf)

ax_tf = map(f -> map(i -> Axis(f[i,1], xgridvisible=false, ygridvisible=false, xlabel = xlabs_tf[i], limits = ((0, 12), (0, 18))), 1:3), f_tf)

#ax_tf = map(f -> Axis(f[1,1], xgridvisible=false, ygridvisible=false, xlabel = L"Frequency ($Hz$)", ylabel = L"Amplitude", limits = ((0, 8), (0, 16))), f_tf)

#ax2_tf = map(f -> map(i -> Axis(f[i,2], xgridvisible=false, ygridvisible=false, xlabel = xlabs_tf[i], ylabel = L"\ddot{u} ($m/sec^2$)"), 1:3), f_tf)

linkyaxes!.(ax)
linkyaxes!.(ax2)
linkyaxes!(ax_th[1], ax_th[2], ax_th[3])
linkyaxes!(ax2_th[1], ax2_th[2], ax2_th[3])
#linkyaxes!.(ax_th)
#linkyaxes!.(ax2_th)
#linkyaxes!.(ax_tf)
#linkyaxes!.(ax2_tf)

cls = reverse([:red, :orange, :green])
δl = map(i -> map(j -> lines!(ax[i][j], t[i][j], δ[i][j], color = cls[j], linewidth = 1.5), 1:3), 1:3)
Ml = map(i -> map(j -> lines!(ax2[i][j], t[i][j], M[i][j], color = cls[j], linewidth = 1.5), 1:3), 1:3)
ratl = map(i -> map(j -> lines!(ax_tf[i][j], freqs[i][j][2:end-1], rat[i][j][2:end-1], color = cls[j], linewidth = 1.5), 1:3), 1:3)
#ratl = map(i -> map(j -> lines!(ax_tf[i], freqs[i][j][2:end-1], rat[i][j][2:end-1], color = cls[j], linewidth = 1.5), 1:3), 1:3)
thvl = map(i -> lines!(ax_th[i], t[2][i], base_v[2][i].Xvelocity .*100, color = :black), 1:3)
thal = map(i -> lines!(ax2_th[i], t[2][i], base_a[2][i] ./1000, color = :black), 1:3)

npgvs = string.("PGV\\;", pgvs)

# I should do center alignment for the axes so that the legend fit nicely
tw = 20
al = map(j -> map(i -> axislegend(ax[j][i], [δl[1][i]], [L"%$(npgvs[i])"], height = tw, margin = (0, 0, 0, 0)), 1:3), 1:3)
map(j -> map(i -> axislegend(ax2[j][i], [δl[1][i]], [L"%$(npgvs[i])"], height = tw, margin = (0, 0, 0, 0)), 1:3), 1:3)
altf = map(j -> map(i -> axislegend(ax_tf[j][i], [δl[1][i]], [L"%$(npgvs[i])"], position = :lt, height = tw, margin = (0, 0, 0, 0)), 1:3), 1:3)
#TEXTLABEL

f_tf2 = Figure()
ax_tf2 = Axis(f_tf2[1,1], xgridvisible=false, ygridvisible=false, ylabel = L"Amplitude", limits = ((0, 8), (0, 30)) )
lines!(ax_tf2, freqs[2][1], rat[2][1])

#=
map(i -> axislegend(ax[1][i], [δl[1][i]], [L"%$(npgvs[i])"], valign = :bottom), 1:3)
map(i -> axislegend(ax2[1][i], [δl[1][i]], [L"%$(npgvs[i])"], valign = :bottom), 1:3)
# =#
#=
map(i ->
Legend(f[i][2,3],
      δl[i],
      npgvs
      ),
      1:3)
# =#

sfp = "/home/hootseer/Documents/underground-diamonds/LaTeX/figures/fragility/"

f_th[3]
#=
save.(string.(sfp, fp, "-EDPs.png"), f)
save.(string.(sfp, "PGV", pgvs, "-TH.png"), f_th)
save.(string.(sfp, fp, "-TF.png"), f_tf)
=#

