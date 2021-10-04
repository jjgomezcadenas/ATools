using CSV
using DataFrames
using Glob
using HDF5

## These should maybe go in a types file
"""
	PetaloDF

Returns Petalo data sets as DataFrames
"""
struct PetaloDF
	volume_names::Vector{String}
	process_names::Vector{String}
	sensor_xyz::DataFrame
	primaries::DataFrame
	vertices::DataFrame
	total_charge::DataFrame
	waveform::DataFrame
end


"""
	MlemLor

Struct representing a LOR
"""
struct MlemLor
    dx::Float32
    x1::Float32
    y1::Float32
    z1::Float32
    x2::Float32
    y2::Float32
    z2::Float32
end


"""
    readdf(dir)

Reads all csv files found in dir and returns a single DataFrame.
"""
function readdf(dir::String)
    files = glob("*.csv",dir)
    dfs   = [CSV.read(file, DataFrame) for file in files]
    evtdf = vcat(dfs...)
end


"""
    writemdf(dir::String, file::String, df::DataFrame)
    #NAME!!
writes a DataFrame to csv file.
"""
function writemdf(dir::String, file::String, df::DataFrame)
    path = joinpath(dir, files)
    CSV.write(path, df)
end


"""
	readh5_dset(path::String, folder::String, dset::String)

read an h5 dataset
"""
function readh5_dset(path::String, folder::String, dset::String)
	h5open(path, "r") do fid
		readh5_dset(fid, folder, dset)
	end
end


"""
	readh5_dset(h5in::HDF5.File, folder::String, dset::String)

read dataset from open hdf5 file.
"""
function readh5_dset(h5in::HDF5.File, folder::String, dset::String)
	g   = h5in[folder]
	dst = read(g, dset)
	return dst
end


"""
	read_abc(path::String)

read abracadabra hdf5 and return relevant data sets
"""
function read_abc(path::String)
	(primaries, sensor_xyz,
	 total_charge, vertices,
	 waveform, volume_names, process_names) = h5open(path, "r") do h5in
		a = readh5_dset(h5in, "MC", "primaries"    ) |> DataFrame
		b = readh5_dset(h5in, "MC", "sensor_xyz"   ) |> DataFrame
		c = readh5_dset(h5in, "MC", "total_charge" ) |> DataFrame
		d = readh5_dset(h5in, "MC", "vertices"     ) |> DataFrame
		e = readh5_dset(h5in, "MC", "waveform"     ) |> DataFrame
		f = readh5_dset(h5in, "MC", "volume_names" )
		g = readh5_dset(h5in, "MC", "process_names")
		return a, b, c, d, e, f, g
	end

	## Are these conversions really necessary?
	function int_conv(cols::Vector{Symbol})
		cols .=> ByRow(Int)
	end

	transform!(primaries , int_conv([:event_id ]), renamecols=false)
	transform!(sensor_xyz, int_conv([:sensor_id]), renamecols=false)
	transform!(total_charge,
		int_conv([:event_id, :sensor_id, :charge]), renamecols=false)
	transform!(waveform,
		int_conv([:event_id, :sensor_id]), renamecols=false)
	transform!(vertices,
		int_conv([:event_id, :track_id, :parent_id, :process_id, :volume_id]),
		renamecols=false)

	return PetaloDF(volume_names,
	                process_names,
					sensor_xyz,
					primaries,
					vertices,
					total_charge,
					waveform)
end


#"""
#    dataframe_to_h5()
#
#Ouput a DataFrame to a HDF5 file.
#"""
#function dataframe_to_h5(args)
#    function define_dattype(df::DataFrame)
#        dtype = HDF5.h5t_create(HDF5.H5T_COMPOUND, )
#    end
#end


"""
	write_lors_hdf5(filename, mlor)
	Write lors in a hdf5 format required by petalorust (mlem algo)
"""
function write_lors_hdf5(filename, mlor)

    function set_datatype(::Type{MlemLor})
        dtype = HDF5.h5t_create(HDF5.H5T_COMPOUND, sizeof(MlemLor))
        HDF5.h5t_insert(dtype, "dx", fieldoffset(MlemLor, 1),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "x1", fieldoffset(MlemLor, 2),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "y1", fieldoffset(MlemLor, 3),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "z1", fieldoffset(MlemLor, 4),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "x2", fieldoffset(MlemLor, 5),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "y2", fieldoffset(MlemLor, 6),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "z2", fieldoffset(MlemLor, 7),
                        datatype(Float32))

        HDF5.Datatype(dtype)
    end

	h5open(filename, "w") do h5f
		dtype  = set_datatype(MlemLor)
		dspace = dataspace(mlor)
		grp    = create_group(h5f, "true_info")## This doesnt seem like a stable name
		dset   = create_dataset(grp, "lors", dtype, dspace)
		write_dataset(dset, dtype, mlor)
	end
end
