using CSV
using DataFrames
using Glob
using HDF5

import Base.@kwdef

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
    Define type for output so general dtype generator can be used easily.
"""
abstract type OutputDataset end


"""
	MlemLor

Struct representing a LOR
"""
struct MlemLor <: OutputDataset
    dx::Float32
    x1::Float32
    y1::Float32
    z1::Float32
    x2::Float32
    y2::Float32
    z2::Float32
end


"""
    EventParameters

Struct representing the parameters for each hemisphere of a selected event.
@kwdef macro allows for keyword argument definitions, improving readability.
"""
@kwdef struct EventParameters <: OutputDataset
    event_id ::Int64   = zero(Int64)
    phot1    ::Bool    = false
    phot2    ::Bool    = false
    nsipm1   ::Int64   = zero(Int64)
    nsipm2   ::Int64   = zero(Int64)
	q1       ::Float32 = zero(Float32)
    q2       ::Float32 = zero(Float32)
	r1       ::Float32 = zero(Float32)
    r2       ::Float32 = zero(Float32)
    r1x      ::Float32 = zero(Float32)
    r2x      ::Float32 = zero(Float32)
	phistd1  ::Float32 = zero(Float32)
    phistd2  ::Float32 = zero(Float32)
	widphi1  ::Float32 = zero(Float32)
    widphi2  ::Float32 = zero(Float32)
	zstd1    ::Float32 = zero(Float32)
    zstd2    ::Float32 = zero(Float32)
	widz1    ::Float32 = zero(Float32)
    widz2    ::Float32 = zero(Float32)
	corrzphi1::Float32 = zero(Float32)
    corrzphi2::Float32 = zero(Float32)
	xt1      ::Float32 = zero(Float32)
    xt2      ::Float32 = zero(Float32)
	yt1      ::Float32 = zero(Float32)
    yt2      ::Float32 = zero(Float32)
	zt1      ::Float32 = zero(Float32)
    zt2      ::Float32 = zero(Float32)
	t1       ::Float32 = zero(Float32)
    t2       ::Float32 = zero(Float32)
	x1       ::Float32 = zero(Float32)
    x2       ::Float32 = zero(Float32)
	y1       ::Float32 = zero(Float32)
    y2       ::Float32 = zero(Float32)
	z1       ::Float32 = zero(Float32)
    z2       ::Float32 = zero(Float32)
	xr1      ::Float32 = zero(Float32)
    xr2      ::Float32 = zero(Float32)
	yr1      ::Float32 = zero(Float32)
    yr2      ::Float32 = zero(Float32)
	zr1      ::Float32 = zero(Float32)
    zr2      ::Float32 = zero(Float32)
	tr1      ::Float32 = zero(Float32)
    tr2      ::Float32 = zero(Float32)
	xb1      ::Float32 = zero(Float32)
    xb2      ::Float32 = zero(Float32)
	yb1      ::Float32 = zero(Float32)
    yb2      ::Float32 = zero(Float32)
	zb1      ::Float32 = zero(Float32)
    zb2      ::Float32 = zero(Float32)
	ta1      ::Float32 = zero(Float32)
    ta2      ::Float32 = zero(Float32)
	xs       ::Float32 = zero(Float32)
    ux       ::Float32 = zero(Float32)
	ys       ::Float32 = zero(Float32)
    uy       ::Float32 = zero(Float32)
	zs       ::Float32 = zero(Float32)
    uz       ::Float32 = zero(Float32)
end


"""
    SimConfiguration

Type to store information about the simulation and analysis done on the data.
Will be extended when full electronics simulation ready!
"""
@kwdef struct SimConfiguration <: OutputDataset
    SiPMPDE::Float32 =    0.3
    ElecSTD::Float32 =    0.05
    SiPMThr::Float32 =    2.0
    SumQmin::Float32 =  100.0
    SumQmax::Float32 = 5000.0
    Ntof   ::Int64   =    7
    NEvent ::Int64   =    0
    Rmin   ::Float32 =  353.0
    Rmax   ::Float32 =  393.0
    CalLin ::Float32 =    0.0 #DOI Calibration linear term, to be implemented
    CalCon ::Float32 =    0.0 #DOI Calibration constant term
    CalBias::Float32 =    0.0 #DOI Calibration bias.
end


## Readers/Writers
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
    readh5_todf(path::String, folder::String, dset::String)
"""
function readh5_todf(path::String, folder::String, dset::String)
    h5open(path, "r") do fid
		readh5_todf(fid, folder, dset)
	end
end


"""
    readh5_todf(h5in::HDF5.File, folder::String, dset::String)
"""
function readh5_todf(h5in::HDF5.File, folder::String, dset::String)
    dst = readh5_dset(h5in, folder, dset)
    return dst |> DataFrame
end


"""
	read_abc(path::String)

read abracadabra hdf5 and return relevant data sets
"""
function read_abc(path::String)
	(primaries, sensor_xyz,
	 total_charge, vertices,
	 waveform, volume_names, process_names) = h5open(path, "r") do h5in
		a = readh5_todf(h5in, "MC", "primaries"    )
		b = readh5_todf(h5in, "MC", "sensor_xyz"   )
		c = readh5_todf(h5in, "MC", "total_charge" )
		d = readh5_todf(h5in, "MC", "vertices"     )
		e = readh5_todf(h5in, "MC", "waveform"     )
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


"""
    read_evtpar(infiles::Vector{String})

Get the selected event parameters from file along with normalisation
and rmin rmax info.
"""
function read_evtpar(infiles::Vector{String})
    rmin   = typemax(Float64)
    rmax   = typemin(Float64)
    norm   = zero(Int64)
    df_vec = DataFrame[]
    for fn in infiles
        s_conf = h5open(fn) do h5in
            sim_conf = readh5_dset(h5in, "configuration", "RunConfiguration")[1]
            push!(df_vec, readh5_todf(h5in, "selected_events", "EventParameters"))
            return sim_conf
        end
        norm += s_conf.NEvent
        rmin  = s_conf.Rmin < rmin ? s_conf.Rmin : rmin
        rmax  = s_conf.Rmax > rmax ? s_conf.Rmax : rmax
    end
    return norm, rmin, rmax, vcat(df_vec...)
end


"""
    generate_hdf5_datatype

returns a datatype object for saving any of the OutputDataset group type to hdf5
"""
function generate_hdf5_datatype(data_type::Type{<:OutputDataset})
    epdtype = HDF5.h5t_create(HDF5.H5T_COMPOUND, sizeof(data_type))
    epnames = fieldnames(data_type)
    eptypes = fieldtypes(data_type)
    for (i, (nm, typ)) in enumerate(zip(epnames, eptypes))
        HDF5.h5t_insert(epdtype, nm, fieldoffset(data_type, i), datatype(typ))
    end
    return HDF5.Datatype(epdtype)
end


"""
	write_lors_hdf5(filename, mlor)
	Write lors in a hdf5 format required by petalorust (mlem algo)
"""
function write_lors_hdf5(filename, mlor, directory::String="reco_info")
	h5open(filename, "w") do h5f
		dtype  = generate_hdf5_datatype(MlemLor)
		dspace = dataspace(mlor)
		grp    = create_group(h5f, directory)
		dset   = create_dataset(grp, "lors", dtype, dspace)
		write_dataset(dset, dtype, mlor)
	end
end
