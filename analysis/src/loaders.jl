module Loaders
    export DataLoader, LazyH5, velocity3d, flowfields_times, span_averages, shear_stress, spans_times, dt_history, Flowfield, all_flowfields, metadata, energy, dissipation_rate, Mesh, mesh
    using ..H5Helpers: load_hdf5_vector_field, load_hdf5_scalar_series, load_hdf5_2d_series
    
    import HDF5
    import JSON

    struct DataLoader
        distribute_save::String
    end

    struct LazyH5
        h5path::String
        dataset_name::String
    end

    function Base.getindex(lazy::LazyH5, slicing...)
        h5 = HDF5.h5open(lazy.h5path, "r")
        dset = h5[lazy.dataset_name]

        tmp = dset[reverse(slicing)...]
        return permutedims(tmp, reverse(1:ndims(tmp)))
    end

    function Base.size(lazy::LazyH5)
        h5 = HDF5.h5open(lazy.h5path, "r")
        dset = h5[lazy.dataset_name]
        dset_size = size(dset)

        return reverse(dset_size)
    end

    function flowfields_path(loader::DataLoader)::String
        return loader.distribute_save * "/flowfields.h5"
    end

    function trajectories_path(loader::DataLoader)::String
        return loader.distribute_save * "/trajectories.h5"
    end

    function spans_path(loader::DataLoader)::String
        return loader.distribute_save * "/span_averages.h5"
    end

    function mesh_path(loader::DataLoader)::String
        return loader.distribute_save * "/mesh.h5"
    end

    #
    # 3D Full flowfields loaders
    #
    
    struct Flowfield
        velocity3d::LazyH5
        time::Array{Float32, 1}
    end

    function velocity3d(loader::DataLoader, lazy::Bool)::Union{LazyH5, Array{Float32, 5}}
        path = flowfields_path(loader)

        if lazy
            return LazyH5(path, "velocity")
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_vector_field(h5, "velocity")
        end
    end

    function flowfields_times(loader::DataLoader, lazy::Bool)::Union{LazyH5, Array{Float32, 1}}
        path = flowfields_path(loader)
        dset = "time"

        if lazy
            return LazyH5(path, dset)
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_scalar_series(h5, dset)
        end
    end

    function all_flowfields(loader::DataLoader)::Flowfield
        v3d = velocity3d(loader, true)
        time = flowfields_times(loader, false)

        return Flowfield(v3d, time)
    end

    #
    # Span average loaders
    #

    function span_averages(loader::DataLoader, lazy::Bool)::Union{LazyH5, Array{Float32, 4}}
        path = spans_path(loader)
        dset = "span_average"

        if lazy
            return LazyH5(path, dset)
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_vector_field(h5, dset)
        end
    end

    function shear_stress(loader::DataLoader, lazy::Bool)::Union{LazyH5, Array{Float32, 2}}
        path = spans_path(loader)
        dset = "shear_stress"

        if lazy
            return LazyH5(path, dset)
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_2d_series(h5, dset)
        end
    end

    function spans_times(loader::DataLoader, lazy::Bool)::Union{LazyH5, Array{Float32, 1}}
        path = spans_path(loader)
        dset = "time"

        if lazy
            return LazyH5(path, dset)
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_scalar_series(h5, dset)
        end
    end

    function energy(loader::DataLoader; lazy::Bool=false)::Union{LazyH5, Array{Float32, 1}}
        path = spans_path(loader)
        dset = "energy"

        if lazy
            return LazyH5(path, dset)
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_scalar_series(h5, dset)
        end
    end

    function dissipation_rate(loader::DataLoader; lazy::Bool=false)::Union{LazyH5, Array{Float32, 1}}
        path = spans_path(loader)
        dset = "dissipation_rate"

        if lazy
            return LazyH5(path, dset)
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_scalar_series(h5, dset)
        end
    end

    #
    # loaders for trajectories
    #

    function dt_history(loader::DataLoader, lazy::Bool)::Union{LazyH5, Array{Float32, 1}}
        path = trajectories_path(loader)
        dset = "dt"

        if lazy
            return LazyH5(path, dset)
        else
            # return the full array (probably bad for large datasets)
            h5 = HDF5.h5open(path)
            load_hdf5_scalar_series(h5, dset)
        end
    end


    function metadata(loader::DataLoader)
        json_path = loader.distribute_save * "/input.json"
        file = open(json_path)
        return JSON.parse(file)
    end

    #
    # Loaders for mesh data
    #

    struct Mesh
        x::Vector{Float32}
        y::Vector{Float32}
        z::Vector{Float32}
    end

    function mesh(loader::DataLoader)::Mesh
        path = mesh_path(loader)
        h5 = HDF5.h5open(path)

        x = load_hdf5_2d_series(h5, "x_grid")[1, :]
        y = load_hdf5_2d_series(h5, "y_grid")[1, :]
        z = load_hdf5_2d_series(h5, "z_grid")[1, :]

        return Mesh(x,y,z)
    end

end
