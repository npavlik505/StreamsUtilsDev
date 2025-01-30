#
#
# mostly lifted from 
# https://github.com/Fluid-Dynamics-Group/selective-modification/blob/763f1b6369a851b374bb918270ac8a80f72f5738/analysis/src/h5_helpers.jl#L1
#
#
module H5Helpers
	import HDF5

	export load_hdf5_vector_field, load_hdf5_scalar_field, load_hdf5_scalar_series, load_hdf5_2d_series

	# load a dataset over specific timestep ranges
	function load_hdf5_vector_field(h5file::HDF5.File, name::String, range)
		dset = h5file[name][:, :, :, :, range]
		return permutedims(dset,  reverse(1:ndims(dset)))
	end

	# load a dataset over specific timestep ranges
	function load_hdf5_vector_field(h5file::HDF5.File, name::String)
		dset = read(h5file[name])
		return permutedims(dset,  reverse(1:ndims(dset)))
	end

	function load_hdf5_scalar_field(h5file::HDF5.File, name::String, range)
		dset = h5file[name][:, :, :, range]
		return permutedims(dset,  reverse(1:ndims(dset)))
	end

	function load_hdf5_scalar_field(h5file::HDF5.File, name::String)
		dset = read(h5file[name])
		return permutedims(dset,  reverse(1:ndims(dset)))
	end

	function load_hdf5_scalar_series(h5file::HDF5.File, name::String)
		dset = h5file[name][:];
		return permutedims(dset,  reverse(1:ndims(dset)))
	end

    function load_hdf5_2d_series(h5file::HDF5.File, name::String)
        dset = h5file[name][:, :];
		return permutedims(dset,  reverse(1:ndims(dset)))
	end

	function load_hdf5_scalar_series(h5file::HDF5.File, name::String, range)
		dset = h5file[name][range];
		return permutedims(dset,  reverse(1:ndims(dset)))
	end
end
