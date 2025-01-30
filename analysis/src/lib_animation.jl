module animation

using Printf
using CairoMakie
using ..Loaders: LazyH5, Mesh

export Rho, XVelocity, YVelocity, ZVelocity, Energy, Formatter, PlottableGroup, Animate, export_all, AxisMeta, setup_ax, component_idx, component_name

#
# component helpers
#
abstract type Component end
struct Rho <: Component end
struct XVelocity <: Component end
struct YVelocity <: Component end
struct ZVelocity <: Component end
struct Energy <: Component end;

function component_idx(x::Component)
    error("component not implemented for " * typeof(x))
end

component_idx(x::Rho) = 1
component_idx(x::XVelocity) = 2
component_idx(x::YVelocity) = 3
component_idx(x::ZVelocity) = 4
component_idx(x::Energy) = 5

component_name(x::Rho) = "density"
component_name(x::XVelocity) = "x velocity"
component_name(x::YVelocity) = "y velocity"
component_name(x::ZVelocity) = "z velocity"
component_name(x::Energy) = "energy (u⃗ ⋅ u⃗)/2"

#
# formatting
#

struct Formatter
	base_string::String
end

# ╔═╡ 6640a86d-3378-48ac-93b7-e97a452979d9
format(fmt::Formatter, idx::Int) = @sprintf "%s_%05i.png" fmt.base_string idx

struct AxisMeta{C <: Component}
	ax::Makie.Axis
	mincolor::Float32
	maxcolor::Float32
	comp::C
	row::Int
end

struct PlottableGroup{T,U,V,W}
    data::LazyH5
	mesh::Mesh
    fig::Makie.Figure
    ax_rho::AxisMeta{T}
    ax_u::AxisMeta{U}
    ax_v::AxisMeta{V}
    ax_w::AxisMeta{W}
end

# ╔═╡ 77e99933-b63f-47f5-922f-4012c2755726
struct Animate
	save_folder::String
	format_name::Formatter
	data::PlottableGroup
end

# ╔═╡ cf8db4d3-9cc2-47b1-bac0-9ab952deb5aa
function Makie.empty!(plt::PlottableGroup)
	empty!(plt.ax_rho.ax)
	empty!(plt.ax_u.ax)
	empty!(plt.ax_v.ax)
	empty!(plt.ax_w.ax)
end

# ╔═╡ 9e756760-5fb2-4969-9b6d-508f571a59dc
function plot_for_idx(plt::PlottableGroup, idx::Int, is_first::Bool)	
	plot_for_idx(plt.fig, plt.ax_rho, idx, is_first, plt.data, plt.mesh)
	plot_for_idx(plt.fig, plt.ax_u, idx, is_first, plt.data, plt.mesh)
	plot_for_idx(plt.fig, plt.ax_v, idx, is_first, plt.data, plt.mesh)
	plot_for_idx(plt.fig, plt.ax_w, idx, is_first, plt.data, plt.mesh)
end

function plot_for_idx(fig::Makie.Figure, ax::AxisMeta{C}, idx::Int, is_first::Bool, data::LazyH5, mesh::Mesh) where C<: Component
    comp_idx = component_idx(ax.comp)

    currslice = data[idx, comp_idx, :, :]

    local plt = contourf!(
		ax.ax,
		mesh.x,
		mesh.y,
		currslice,
		colormap = :balance,
		#colorrange = (ax.mincolor, ax.maxcolor),
        levels = range(ax.mincolor, ax.maxcolor, 40)
		#levels=40
	)

    if is_first
        Colorbar(fig[ax.row,2], plt);
    end
end


function export_all(animate::Animate, start_idx::Int, end_idx::Int, decimate::Int)

	#if Base.Filesystem.ispath(animate.save_folder)
	#	Base.Filesystem.rm(animate.save_folder, force=true, recursive=true)
	#end

	#Base.Filesystem.mkdir(animate.save_folder)

	for i in start_idx:decimate:end_idx
        is_first = i == start_idx
		plot_for_idx(animate.data, i, is_first)

		save_name = format(animate.format_name, i)
		Makie.save(animate.save_folder * "/" * save_name, animate.data.fig)

		empty!(animate.data)
	end

	# output_path = "$(animate.save_folder)/output.mp4"
	# cmd = `animate $framerate $output_path folder $(animate.save_folder)`
	# run(cmd)
end

function setup_ax(fig::Makie.Figure, comp::C, data::LazyH5, row::Int)::AxisMeta where C<: Component
	title = "span average $(component_name(comp))"
	comp_idx = component_idx(comp)
	ax = Axis(fig[row, 1], xlabel = "x", ylabel = "y", title = title)

	mincolor = minimum(data[:, comp_idx, :, :])
	maxcolor = maximum(data[:, comp_idx, :, :])

	return AxisMeta(ax, mincolor, maxcolor, comp, row)
end

end # module lib_animation
