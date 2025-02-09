### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 9c3e3ffa-fb9d-4eb4-828e-c68049b2d88c
using HDF5

# ╔═╡ 9171f7c3-b9b8-48bd-b3df-39cc5148d132
using Reexport

# ╔═╡ a524e54e-050a-46d2-ae47-d91b54bf3b2f
using Makie

# ╔═╡ 72a38c24-8f03-47b8-bce1-604e8a26a19e
using CairoMakie

# ╔═╡ a6ffab23-ce0d-489d-bd13-b285ba5fe30e
using JSON

# ╔═╡ 3522fd50-ec9b-49bc-a7b6-eab4af5adaa4
using LaTeXStrings

# ╔═╡ 854b1497-f598-46b7-8bc6-5fd8e07b5487
using Printf

# ╔═╡ 8fb2a138-2b49-42e1-832e-dcaf1fadfb97
# using GLMakie

# ╔═╡ dfd1aba5-2db1-490a-94a8-ca24fabd7f31
import Statistics

# ╔═╡ ea91217d-2994-458c-b35d-6c33b810e047
import Trapz

# ╔═╡ c3f5306c-4994-11ed-3c5a-f5804205840d
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 1c484032-7c09-45f0-a50c-95082ac6b921
analysis = ingredients("./src/analysis.jl").analysis

# ╔═╡ f0dc3b51-5041-4f07-8058-065bfb86ad67
anim = analysis.animation

# ╔═╡ aa909845-6bda-468b-b797-daeb05ad4fb4
names(analysis)

# ╔═╡ 402bc98c-8741-4426-8348-0fb9619b03c2
names(analysis.animation)

# ╔═╡ 4a94a12b-2c2a-4166-9b55-14f5cd0fa514
pwd()

# ╔═╡ b41f5510-a79a-43d6-b7bc-4be57c089502
const DPI = 300

# ╔═╡ 50b0266b-0a66-42c6-8273-6b779998c74f
md"# Data Loading"

# ╔═╡ 9d385399-ffd7-4e0b-a143-1a49119a5280
BASE_PATH = "/home/brooks/github/streams-utils/distribute/"

# ╔═╡ dd5a54f7-5773-4983-a1e4-08e60231198c
mode = "jet_validation"

# ╔═╡ 824ff024-6a7f-40fc-b242-7ee24a7b3d31
batch_name = @sprintf "%s_%02i" mode 19

# ╔═╡ 2591ee3d-1eca-4f36-b385-c32c8415a8ba
folder = "jet_validation_pos_1_amplitude_300_points"

# ╔═╡ 85c118eb-a71c-40be-abbd-d665015926cd
# PATH = "../output/distribute_save"
PATH = "$BASE_PATH/$mode/$batch_name/$batch_name/$folder/"

# ╔═╡ 72281877-92fe-49e8-aee5-5ae524512e15
Base.Filesystem.abspath("../output/distribute_save/flowfields.h5")

# ╔═╡ 06af6a34-6cf4-448a-9dda-53b2de0ba7eb
loader = analysis.DataLoader(PATH)

# ╔═╡ e7cd911e-22ec-46ba-8122-e15e1fb67719
velocity3d = analysis.velocity3d(loader, true); size(velocity3d)

# ╔═╡ c93925f2-c477-44f1-97bf-4f6ac429a1da
span_averages = analysis.span_averages(loader, true); size(span_averages)

# ╔═╡ 52c93fe7-87f0-487b-9cf7-cfc86b2e6aa5
numwrites, nvec, nx, ny, nz = size(velocity3d)

# ╔═╡ b73336ba-e435-4616-968d-a90cc3167ee7
shear_stress = analysis.shear_stress(loader, false); size(shear_stress)

# ╔═╡ b47fe2b5-dcf6-4f68-8391-261063a407cb
energy  = analysis.energy(loader); size(energy)

# ╔═╡ 77285fd2-7d84-4c82-867b-954367d12a3d
mean_energy = Statistics.mean(energy)

# ╔═╡ 226933c7-020d-4117-a86e-e6739ab9f21f
normalized_energy = energy ./ mean_energy

# ╔═╡ 1d50baee-87df-4023-9890-5447946b6932
# check if any NAN data in energy
any(x -> x == true, isnan.(energy))

# ╔═╡ 908a160c-b941-466f-b291-f172903b8143
dissipation_rate  = analysis.dissipation_rate(loader); size(dissipation_rate)

# ╔═╡ b5e4a614-e278-448a-b4fb-0f37ba527134
mean_dissipation_rate = Statistics.mean(dissipation_rate)

# ╔═╡ 40e512c4-e03b-46d1-b682-dd41d44d685e
normalized_dissipation_rate = dissipation_rate ./ mean_dissipation_rate

# ╔═╡ 39da146f-dd8e-4769-b3f3-9b675b6862c1
# check if any NAN data in dissipation rate
any(x -> x == true, isnan.(dissipation_rate))

# ╔═╡ c7c2fc88-27c5-407f-aba7-933cd9715b9e
span_times = analysis.spans_times(loader, false)

# ╔═╡ 0c1b229d-0015-4984-a1ac-b8a5b05680fc
meta = analysis.metadata(loader)

# ╔═╡ cd76152a-92f5-4e3b-94b5-6c5f47c6db15
const mesh = analysis.mesh(loader)

# ╔═╡ 3d57e1af-000d-47a2-b5a1-738d88cc4ecf
nz

# ╔═╡ a6d90dfa-e11c-4d62-97c8-6d43c9e0d962
lx = meta["x_length"]

# ╔═╡ 22cb7ad5-9b24-45c2-b384-8b746a4bb36d
ly = meta["y_length"]

# ╔═╡ 33ceb38a-f492-4f0f-b86d-6f5429065f9f
md"# Animations"

# ╔═╡ cbd9fa26-7063-47f3-8091-f898636d8e42
const should_animate = false

# ╔═╡ 54c36eac-4e16-4c41-95fd-1528a4304ed2
begin
if should_animate
	local height = 300.
	local width = (height) / ly * lx |> floor |> Int
	local res = (width, height)
	local framerate = 120

	local fig = Figure(resolution = (height * 4, width), dpi = 300)

	local rho_ax = anim.setup_ax(fig, anim.Rho(), span_averages, 1)
	local u_ax = anim.setup_ax(fig, anim.XVelocity(), span_averages, 2)
	local v_ax = anim.setup_ax(fig, anim.YVelocity(), span_averages, 3)
	local energy_ax = anim.setup_ax(fig, anim.Energy(), span_averages,4)

	local plottable_group = anim.PlottableGroup(span_averages, mesh, fig, rho_ax, u_ax, v_ax, energy_ax)

	local save_folder = PATH * "/animation_bak/"
	fmt = anim.Formatter("rho_u_v_w")

	local animate = anim.Animate(save_folder, fmt, plottable_group)

	@time anim.export_all(animate, 60, 1000, 1010)
end
end

# ╔═╡ e6abf6a4-b05e-4ce3-90d1-dd181512782b
dropdims(Statistics.mean(span_averages[:, 3, :, :], dims=1), dims=1)

# ╔═╡ a90e8c14-97d0-48a1-8765-905e37ba2be6
md"# Span wise plots"

# ╔═╡ aa859cd0-6eab-49b4-9ccc-61475085a0be
md"## Simple Span Average"

# ╔═╡ ffed6dfd-1dd8-4cd0-aa62-bb5ca021de54
const span_height = 1200

# ╔═╡ 6b629692-820b-4d9e-bb1c-bad15aae3a04
const span_width = span_height *lx / ly * 5/6 |> floor |> Int

# ╔═╡ 338fc8c2-72ff-49e1-b402-a2d3cca306ee
# const span_res = (span_width, span_height+100)
# const span_res = (span_width, span_height*2)
const span_res = (1000, 1000)

# ╔═╡ 8a251a3d-7c0f-483b-9c71-091606fad315
const span_fontsize = 25

# ╔═╡ a367f9d4-30da-4134-9e9b-d76e3ce90a07
component = anim.YVelocity()

# ╔═╡ 15adb258-8d80-47de-913e-b2a2d3310364
size(span_averages)

# ╔═╡ dd9015fb-381a-4021-b529-0c6197430fb8
mesh.x |> length

# ╔═╡ 2635809d-7549-4db5-8a22-e7ee268ef053
mesh.y

# ╔═╡ fb9a5c2e-4ffe-41b7-9381-0528e6ac0253
span_times |> maximum

# ╔═╡ bf85a4ef-b71f-455f-9ccf-623f63b8c387
function overset_mesh(ax::Makie.Axis, mesh::analysis.Mesh)
	x0 = minimum(mesh.x)
	x1 = maximum(mesh.x)

	alpha = 0.4

	for y in mesh.y
		lines!(
			ax,
			[x0, x1],
			[y, y],
			color = (:black, alpha),
			linewidth = 1
		)
	end

	y0 = minimum(mesh.y)
	y1 = maximum(mesh.y)

	for x in mesh.x
		lines!(
			ax,
			[x, x],
			[y0, y1],
			color = (:black, alpha),
			linewidth = 1
		)
	end
end

# ╔═╡ 88e1422f-08ac-48c2-8583-3e76cee6c3de
begin
	local fig = Figure(
		resolution=span_res, 
		dpi=300, fontsize = span_fontsize)

	local idx = 20

	local y_mesh = mesh.y
	local data = span_averages[idx, anim.component_idx(component), :, :]

	local data_shear = shear_stress[idx, :]
	# curr_time = span_times[idx]

	local data_max = max(maximum(data), abs(minimum(data)))

	local time = span_times[idx]

	local ax = Axis(fig[1,1], 
		# title = "Span average y velocity t = $curr_time sec",
		title = "Span average $(anim.component_name(component)) at t = $time",
		xlabel = "x",
		ylabel = "y"
	)
	xlims!(ax, 0, lx)
	ylims!(ax, 0, maximum(mesh.y))

		# ylims!(ax, 0, 0.6)

	# colsize!(fig.layout, 1, Aspect(1, lx/ly))
	# resize_to_layout!(fig)

	# local mincolor = minimum(data)
	# local maxcolor = maximum(data)

	local maxcolor = max(abs(minimum(data)), abs(maximum(data)))
	local mincolor = -maxcolor

	println(minimum(data))
	local plt = contourf!(
		ax,
		mesh.x,
		y_mesh,
		data,
		colormap = :balance,
		levels = range(mincolor, maxcolor, 100),
	)
	Colorbar(fig[1,2], plt)

	overset_mesh(ax, mesh)

	# local ax_shear = Axis(fig[2,1], 
	# 	title = "wall shear stress",
	# 	xlabel = "x",
	# 	ylabel = "τ"
	# )

	# scatter!(
	# 	ax_shear,
	# 	mesh.x,
	# 	data_shear,
	# 	markersize = 4
	# )

	# ylims!(ax_shear, -.005, 0.018)

	fig
end

# ╔═╡ badd1101-8d44-4961-a22b-651819d5c927
md"## Time Averaged Span Average"

# ╔═╡ da6c4d34-25bf-461a-beac-5581213272e9
begin
	local fig = Figure(resolution=span_res, dpi=300, fontsize = span_fontsize)

	local idx = 1

	# time slicing indicies
	local start_idx = 50
	local end_idx = 500
	local y_slice = [:]
	data = Statistics.mean(span_averages[start_idx:end_idx, anim.component_idx(component), :, y_slice...], dims=1)
	data = dropdims(data, dims = 1)

	# data = span_averages[start_idx, 3, :, y_slice...]
	data_shear = shear_stress[idx, :]
	curr_time = span_times[idx]

	local data_max = max(maximum(data), abs(minimum(data)))

	local start_time = span_times[start_idx]
	local end_time = span_times[end_idx]

	local ax = Axis(fig[1,1], 
		# title = "Span average y velocity t = $curr_time sec",
		title = "Span & Temporal averaged y velocity in quiescent flow",
		xlabel = "x",
		ylabel = "y"
	)
	
	xlims!(ax, 0, lx)
	ylims!(ax, 0, ly)

	local maxcolor = max(abs(minimum(data)), abs(maximum(data)))
	println(minimum(data))
	local plt = contourf!(
		ax,
		mesh.x,
		mesh.y[y_slice...],
		data,
		colormap = :balance,
		levels = range(-maxcolor, maxcolor, 100),
	)
	Colorbar(fig[1,2], plt)

	# local ax_shear = Axis(fig[2,1], 
	# 	title = "wall shear stress",
	# 	xlabel = "x",
	# 	ylabel = "τ"
	# )

	# scatter!(
	# 	ax_shear,
	# 	xgrid,
	# 	data_shear,
	# 	markersize = 4
	# )

	# ylims!(ax_shear, -.005, 0.018)

	fig
end

# ╔═╡ f6cfea66-7879-46d2-bc71-077662da21a7
width

# ╔═╡ 4ca0600e-bab5-4439-92bb-22351ff93fe9
size(span_averages)

# ╔═╡ 2ecad180-37c3-4278-8886-e8d2ebeff3b7
begin
	local fig = Figure(resolution = (900, 800))

	
	# local indexes = [1, 10, 25, 50]
	local indexes = [1, 3, 7, 20]
	local markers = [:circle, :circle, :circle, :circle]
	local sizes = [30, 26, 20, 14]

	local set_y = 2
	
	local ax = Axis(fig[1,1], xlabel = "x location", ylabel = "y velocity", title = "jet velocity profile at y=$set_y")
	local slot_start = 100
	local slot_end = 200

	for (idx, marker, size) in zip(indexes, markers, sizes)
		local x = slot_start:slot_end
		# local x = 33:66
		local component = 3
		local y = span_averages[idx, component, x, set_y]
		local time = span_times[idx]
	
		scatter!(
			ax,
			x,
			y,
			label = (@sprintf "t = %.2f s" time),
			marker = marker,
			markersize=size
		)
	end

	lines!(
		ax,
		[slot_start, slot_end],
		[1.0, 1.0]
	)
	# lines!(
	# 	ax,
	# 	[slot_start, slot_end],
	# 	[0.85, 0.85]
	# )
	# lines!(
	# 	ax,
	# 	[slot_start, slot_end],
	# 	[0.9, 0.9]
	# )

	axislegend()
	fig
	# y
end

# ╔═╡ 0e9baa98-67e6-4fe4-a4b3-12da025981eb
md"## Shear Stress / Dissipation / Energy Plots"

# ╔═╡ b91c6497-5bde-4488-9d00-94b514f38334
shear_stress

# ╔═╡ 2c08ac32-fcfa-499e-8811-aa38e86ad975
integral_shear_stress = Trapz.trapz((mesh.x), shear_stress); size(integral_shear_stress)

# ╔═╡ c211ea51-65ef-4175-be27-2489e2c70c9c
zeros_length_shear = zeros(length(span_times))

# ╔═╡ 7ab8a183-adb5-4a1f-acf6-ea774639dcdf
ones_length_shear = ones(length(span_times))

# ╔═╡ 6095ab51-32c0-44b7-9650-217f10a39da7
normalized_integral_shear_stress = integral_shear_stress ./ Statistics.mean(integral_shear_stress)

# ╔═╡ 26a36735-c33b-4f28-8187-7bfc675035ea
begin
	local height = 1200
	local width = 1600
	local fig = Figure(resolution = (width, height), dpi = DPI, fontsize = 30)

	local ax = Axis3(fig[1,1], 
		xlabel=L"E / \overline{E} ", 
		ylabel=L"\tau_w / \overline{\tau_w}",
		zlabel = L"D / \overline{D}"
	)

	Emin = 0.97
	Emax = 1.17

	Emax = maximum(normalized_energy) * 1.02
	Emin = minimum(normalized_energy) * 0.98
	
	shear_max = maximum(normalized_integral_shear_stress) * 1.02
	shear_min = minimum(normalized_integral_shear_stress) * 0.98

	dissipation_max = maximum(normalized_dissipation_rate) * 1.02
	dissipation_min = minimum(normalized_dissipation_rate) * 0.4

	xlims!(ax, Emin, Emax)
	ylims!(ax, shear_min, shear_max)
	zlims!(ax, dissipation_min, dissipation_max)

	lines!(
		ax,
		normalized_energy,
		normalized_integral_shear_stress,
		normalized_dissipation_rate,
		linewidth=4
	)

	# E vs tau
	lines!(
		ax,
		normalized_energy,
		normalized_integral_shear_stress,
		ones_length_shear.*dissipation_min,
		linestyle = :dash,
		color = :black
	)

	# E vs D
	lines!(
		ax,
		normalized_energy,
		ones_length_shear.*shear_max,
		normalized_dissipation_rate,
		linestyle = :dash,
		color = :black
	)

	# D vs tau
	lines!(
		ax,
		ones_length_shear*Emax,
		normalized_integral_shear_stress,
		normalized_dissipation_rate,
		linestyle = :dash,
		color = :black
	)

	function scatter_for_idx(idx)
		E_ = normalized_energy[idx]
		tau_ = normalized_integral_shear_stress[idx]
		D_ = normalized_dissipation_rate[idx]
	
		Evals = [E_, E_, E_, Emax]
		TauVals = [tau_, tau_, shear_max, tau_]
		DVals = [D_, dissipation_min, D_, D_]
		return Evals, TauVals, DVals
	end

	for i in [1, 460, 2000, 5000] 
		scatter!(
			ax,
			scatter_for_idx(i)...,
			markersize = 20,
			label = @sprintf "t = %0.2f" span_times[i]
		)
	end

	axislegend()


	fig
end

# ╔═╡ cfabcc4b-b414-4f57-aaed-936794c715be
begin
	local height = 800
	local width = 800
	local fig = Figure(resolution = (width, height))

	local ax = Axis(fig[1,1], 
		xlabel="time [s]",
		ylabel=L"\tau_w",
		title = "Integral shear stress over time"
	)

	scatter!(
		ax,
		span_times,
		integral_shear_stress,
	)

	local ax = Axis(fig[2,1], 
		xlabel="time [s]",
		ylabel=L"\tau_w / \overline{\tau_w}",
		title = "Normalized integral shear stress over time"
	)
	
	scatter!(
		ax,
		span_times,
		normalized_integral_shear_stress,
	)


	fig
end

# ╔═╡ cf01bb77-9691-43e0-be5a-98756586aa9f
Threads.nthreads()

# ╔═╡ 29ba1511-0b1c-473f-a7f8-f2a88408ca1b
md"## Determine timestep to use"

# ╔═╡ 60163a70-1970-4855-b176-3c400a75c93c
dt_values = analysis.dt_history(loader, false)

# ╔═╡ b7274ebd-b883-4cdc-a8a7-42f491b4bfa6
begin
	res = 800, 600
	local fig = Figure(resolution=res)

	min_dt = minimum(dt_values)
	local ax = Axis(fig[1,1], title = "time step frequency ($nx, $ny, $nz). min dt = $min_dt", xlabel = "dt", ylabel = "frequency")

	hist!(
		ax,
		dt_values,
		bins=30
	)

	fig
end

# ╔═╡ e3b84623-d9b2-4b1e-8b0f-07cdd0fc069f
min_dt

# ╔═╡ a7d759c4-4287-4259-834d-58859655cf20
min_dt *0.9

# ╔═╡ eeef4d2e-3f6a-4f82-9d58-920ab38aecde
0.0009377425f0 + 0.0

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
HDF5 = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Reexport = "189a3867-3050-52da-a836-e630ba90ab69"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
Trapz = "592b5752-818d-11e9-1e9a-2b8ca4a44cd1"

[compat]
CairoMakie = "~0.9.0"
HDF5 = "~0.16.12"
JSON = "~0.21.3"
LaTeXStrings = "~1.3.0"
Makie = "~0.18.0"
Reexport = "~1.2.2"
Trapz = "~2.0.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "51c8fb62e64179d5a70c6324e37e4158c458bf2e"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "5c0b629df8a5566a06f5fef5100b53ea56e465a0"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.2"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "SnoopPrecompile"]
git-tree-sha1 = "f53b586e9489163ece213144a5a6417742f0388e"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.9.0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "04db820ebcfc1e053bd8cbb8d8bccf0ff3ead3f7"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.76"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "802bfc139833d2ba893dd9e62ba1767c88d708ae"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.5"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "38a92e40157100e796690421e34a11c107205c86"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "12a584db96f1d460421d5fb8860822971cdb8455"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.4"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "678d136003ed5bceaab05cf64519e3f956ffa4ba"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.9.1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HDF5]]
deps = ["Compat", "HDF5_jll", "Libdl", "Mmap", "Random", "Requires"]
git-tree-sha1 = "19effd6b5af759c8aaeb9c77f89422d3f975ab65"
uuid = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
version = "0.16.12"

[[deps.HDF5_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenSSL_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "4cc2bb72df6ff40b055295fdef6d92955f9dede8"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.12.2+2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "842dd89a6cb75e02e85fdd75c760cdc43f5d6863"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.6"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "3f91cd3f56ea48d4d2a75c2a65455c5fc74fa347"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.3"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "InteractiveUtils", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "MiniQhull", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun"]
git-tree-sha1 = "51e40869d076fbff25ab61d0aa3e198d80176c75"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.18.0"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "b87650f61f85fc2d4fb5923a479dbf05ba65ae4d"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.5.0"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test", "UnicodeFun"]
git-tree-sha1 = "7f837e1884f1ef84984c919fc7a00638cff1e6d1"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.5.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.MiniQhull]]
deps = ["QhullMiniWrapper_jll"]
git-tree-sha1 = "9dc837d180ee49eeb7c8b77bb1c860452634b0d1"
uuid = "978d7f02-9e05-4691-894f-ae31a51d76ca"
version = "0.4.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "5a9ea4b9430d511980c01e9f7173739595bbd335"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.2"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "f809158b27eba0c18c269cf2a2be6ed751d3e81d"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.17"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "84a314e3926ba9ec66ac097e3635e270986b0f10"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.9+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QhullMiniWrapper_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Qhull_jll"]
git-tree-sha1 = "607cf73c03f8a9f83b36db0b86a3a9c14179621f"
uuid = "460c41e3-6112-5d7f-b78c-b6823adb3f2d"
version = "1.0.0+1"

[[deps.Qhull_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "695c3049ad94fa38b7f1e8243cdcee27ecad0867"
uuid = "784f63db-0788-585a-bace-daefebcd302b"
version = "8.0.1000+0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "3c009334f45dfd546a16a57960a821a1a023d241"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.5.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
git-tree-sha1 = "7dbc15af7ed5f751a82bf3ed37757adf76c32402"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.1"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "2436b15f376005e8790e318329560dcc67188e84"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.3"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "8c6ac65ec9ab781af05b08ff305ddc727c25f680"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.12"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "70e6d2da9210371c927176cb7a56d41ef1260db7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Trapz]]
git-tree-sha1 = "79eb0ed763084a3e7de81fe1838379ac6a23b6a0"
uuid = "592b5752-818d-11e9-1e9a-2b8ca4a44cd1"
version = "2.0.3"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╠═9c3e3ffa-fb9d-4eb4-828e-c68049b2d88c
# ╠═9171f7c3-b9b8-48bd-b3df-39cc5148d132
# ╠═a524e54e-050a-46d2-ae47-d91b54bf3b2f
# ╠═72a38c24-8f03-47b8-bce1-604e8a26a19e
# ╠═8fb2a138-2b49-42e1-832e-dcaf1fadfb97
# ╠═a6ffab23-ce0d-489d-bd13-b285ba5fe30e
# ╠═3522fd50-ec9b-49bc-a7b6-eab4af5adaa4
# ╠═dfd1aba5-2db1-490a-94a8-ca24fabd7f31
# ╠═ea91217d-2994-458c-b35d-6c33b810e047
# ╠═854b1497-f598-46b7-8bc6-5fd8e07b5487
# ╠═c3f5306c-4994-11ed-3c5a-f5804205840d
# ╠═1c484032-7c09-45f0-a50c-95082ac6b921
# ╠═f0dc3b51-5041-4f07-8058-065bfb86ad67
# ╠═aa909845-6bda-468b-b797-daeb05ad4fb4
# ╠═402bc98c-8741-4426-8348-0fb9619b03c2
# ╠═4a94a12b-2c2a-4166-9b55-14f5cd0fa514
# ╠═b41f5510-a79a-43d6-b7bc-4be57c089502
# ╠═50b0266b-0a66-42c6-8273-6b779998c74f
# ╠═9d385399-ffd7-4e0b-a143-1a49119a5280
# ╠═dd5a54f7-5773-4983-a1e4-08e60231198c
# ╠═824ff024-6a7f-40fc-b242-7ee24a7b3d31
# ╠═2591ee3d-1eca-4f36-b385-c32c8415a8ba
# ╠═85c118eb-a71c-40be-abbd-d665015926cd
# ╠═72281877-92fe-49e8-aee5-5ae524512e15
# ╠═06af6a34-6cf4-448a-9dda-53b2de0ba7eb
# ╠═e7cd911e-22ec-46ba-8122-e15e1fb67719
# ╠═c93925f2-c477-44f1-97bf-4f6ac429a1da
# ╠═52c93fe7-87f0-487b-9cf7-cfc86b2e6aa5
# ╠═b73336ba-e435-4616-968d-a90cc3167ee7
# ╠═b47fe2b5-dcf6-4f68-8391-261063a407cb
# ╠═77285fd2-7d84-4c82-867b-954367d12a3d
# ╠═226933c7-020d-4117-a86e-e6739ab9f21f
# ╠═1d50baee-87df-4023-9890-5447946b6932
# ╠═908a160c-b941-466f-b291-f172903b8143
# ╠═b5e4a614-e278-448a-b4fb-0f37ba527134
# ╠═40e512c4-e03b-46d1-b682-dd41d44d685e
# ╠═39da146f-dd8e-4769-b3f3-9b675b6862c1
# ╠═c7c2fc88-27c5-407f-aba7-933cd9715b9e
# ╠═0c1b229d-0015-4984-a1ac-b8a5b05680fc
# ╠═cd76152a-92f5-4e3b-94b5-6c5f47c6db15
# ╠═3d57e1af-000d-47a2-b5a1-738d88cc4ecf
# ╠═a6d90dfa-e11c-4d62-97c8-6d43c9e0d962
# ╠═22cb7ad5-9b24-45c2-b384-8b746a4bb36d
# ╠═33ceb38a-f492-4f0f-b86d-6f5429065f9f
# ╠═cbd9fa26-7063-47f3-8091-f898636d8e42
# ╠═54c36eac-4e16-4c41-95fd-1528a4304ed2
# ╠═e6abf6a4-b05e-4ce3-90d1-dd181512782b
# ╠═a90e8c14-97d0-48a1-8765-905e37ba2be6
# ╠═aa859cd0-6eab-49b4-9ccc-61475085a0be
# ╠═ffed6dfd-1dd8-4cd0-aa62-bb5ca021de54
# ╠═6b629692-820b-4d9e-bb1c-bad15aae3a04
# ╠═338fc8c2-72ff-49e1-b402-a2d3cca306ee
# ╠═8a251a3d-7c0f-483b-9c71-091606fad315
# ╠═a367f9d4-30da-4134-9e9b-d76e3ce90a07
# ╠═15adb258-8d80-47de-913e-b2a2d3310364
# ╠═dd9015fb-381a-4021-b529-0c6197430fb8
# ╠═2635809d-7549-4db5-8a22-e7ee268ef053
# ╠═fb9a5c2e-4ffe-41b7-9381-0528e6ac0253
# ╠═bf85a4ef-b71f-455f-9ccf-623f63b8c387
# ╠═88e1422f-08ac-48c2-8583-3e76cee6c3de
# ╠═badd1101-8d44-4961-a22b-651819d5c927
# ╠═da6c4d34-25bf-461a-beac-5581213272e9
# ╠═f6cfea66-7879-46d2-bc71-077662da21a7
# ╠═4ca0600e-bab5-4439-92bb-22351ff93fe9
# ╠═2ecad180-37c3-4278-8886-e8d2ebeff3b7
# ╠═0e9baa98-67e6-4fe4-a4b3-12da025981eb
# ╠═b91c6497-5bde-4488-9d00-94b514f38334
# ╠═2c08ac32-fcfa-499e-8811-aa38e86ad975
# ╠═c211ea51-65ef-4175-be27-2489e2c70c9c
# ╠═7ab8a183-adb5-4a1f-acf6-ea774639dcdf
# ╠═6095ab51-32c0-44b7-9650-217f10a39da7
# ╠═26a36735-c33b-4f28-8187-7bfc675035ea
# ╠═cfabcc4b-b414-4f57-aaed-936794c715be
# ╠═cf01bb77-9691-43e0-be5a-98756586aa9f
# ╠═29ba1511-0b1c-473f-a7f8-f2a88408ca1b
# ╠═60163a70-1970-4855-b176-3c400a75c93c
# ╠═b7274ebd-b883-4cdc-a8a7-42f491b4bfa6
# ╠═e3b84623-d9b2-4b1e-8b0f-07cdd0fc069f
# ╠═a7d759c4-4287-4259-834d-58859655cf20
# ╠═eeef4d2e-3f6a-4f82-9d58-920ab38aecde
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
