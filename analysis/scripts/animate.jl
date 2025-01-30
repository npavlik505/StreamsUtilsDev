# usage:
# julia ./analysis/scripts/animate.jl <start idx> <end idx> <decimate number> <directory list>
include("/home/brooks/github/streams-utils/analysis/src/analysis.jl")

using .analysis
using .analysis: animation as anim
using CairoMakie

START_IDX = parse(Int, ARGS[1])
END_IDX = parse(Int, ARGS[2])
DECIMATE = parse(Int, ARGS[3])

for PATH in split(ARGS[4])
    loader = DataLoader(PATH)

    mesh = analysis.mesh(loader)
    meta = metadata(loader)
    span_averages = analysis.span_averages(loader, true)
    lx = meta["x_length"]
    ly = meta["y_length"]

    # setup figure parameters
    height = 300.
    width = height * lx / ly |> floor |> Int
    res = (width, 4*height)

    fig = Figure(resolution = res, dpi = 300)

    # setup axes
    rho_ax = anim.setup_ax(fig, anim.Rho(), span_averages, 1)
    u_ax = anim.setup_ax(fig, anim.XVelocity(), span_averages, 2)
    v_ax = anim.setup_ax(fig, anim.YVelocity(), span_averages, 3)
    energy_ax = anim.setup_ax(fig, anim.Energy(), span_averages,4)

    plottable_group = anim.PlottableGroup(span_averages, mesh, fig, rho_ax, u_ax, v_ax, energy_ax)

    # export information
    save_folder = PATH * "/animation/"
    fmt = anim.Formatter("rho_u_v_w")

    # run the animation
    animate = anim.Animate(save_folder, fmt, plottable_group)

    anim.export_all(animate, START_IDX, END_IDX, DECIMATE)
end
