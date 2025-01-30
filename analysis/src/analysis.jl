module analysis
    include("./h5_helpers.jl")
    include("./loaders.jl")
    include("./lib_animation.jl")
    include("./getters.jl")

    using Reexport
    @reexport using .H5Helpers: load_hdf5_vector_field, load_hdf5_scalar_field, load_hdf5_scalar_series, load_hdf5_2d_series
    @reexport using .Loaders: DataLoader, LazyH5, velocity3d, flowfields_times, span_averages, shear_stress, spans_times, dt_history, Flowfield, all_flowfields, metadata, energy, dissipation_rate, Mesh, mesh

    export test

    function test()
        println("test results!")
    end

end # module analysis
