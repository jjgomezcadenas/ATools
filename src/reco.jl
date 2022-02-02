using DataFrames
using LinearAlgebra
using PhysicalConstants.CODATA2018
using Unitful

import Unitful:
    nm, μm, mm, cm, ns, μs, ms, ps, s


"""
    set_units(df::DataFrame)

Return a dataframe with the same structure as the input but with length and
time units set.
"""
function set_units(df::DataFrame)
    ## mm columns, assumes structure as 2021-10-05, should be generalised
    len_cols = [:r1, :r2, :r1x, :r2x, :x1, :x2, :xb1, :xb2, :xr1, :xr2,
        :xs, :xt1, :xt2, :y1, :y2, :yb1, :yb2, :yr1, :yr2, :ys, :yt1, :yt2, :z1,
        :z2, :zb1, :zb2, :zr1, :zr2, :zs, :zt1, :zt2]

    # ns cols:
    time_cols = [:t1, :t2, :ta1, :ta2, :tr1, :tr2]

    units_df = transform(df, len_cols .=> (x -> x * mm), renamecols=false)
    transform!(units_df, time_cols .=> (x -> x * ns), renamecols=false)
    return units_df
end


"""
	radial_correction(x::Vector{<:Real}, y::Vector{<:Real},
                      z::Vector{<:Real}, r::Vector{<:Real})
Computes the x, y position of the interaction from a radius
of interaction and the x, y position from the SiPM barycentre
Kept for backwards compatibility, z argument pointless
"""
function radial_correction(x::Vector{<:Real}, y::Vector{<:Real},
                  z::Vector{<:Real}, r::Vector{<:Real})
    xy = reinterpret(reshape, Float32, calculate_xy.(x, y, r))
    xy[1,:], xy[2,:], z
end


"""
    calculate_xy(x1::Real, y1::Real, r::Real)
Calculate the xy position of a ray at r given x1 and y1 at a different r
"""
function calculate_xy(x1::Real, y1::Real, r::Real)
    ϕ = atan(y1, x1)
    x = r * cos(ϕ)
    y = r * sin(ϕ)
    return x, y
end


"""
    predict_interaction_radius
Given a calibration funcion and the physical limits of the Detector
and function return the radius of interaction (maxr - DOI).
"""
function predict_interaction_radius(cal_func::Function,
        minr::Real, maxr::Real, bias::Real=zero(Real))
  function prediction(sigmas::Vector{<:Real})
    rpred = cal_func.(sigmas) .+ bias
    rpred[rpred .< minr] .= minr
    rpred[rpred .> maxr] .= maxr
    return rpred
  end
end


"""
    time_of_flight(df::DataFrame, ri::Symbol, rsipm::Real, n::Real)

Calculate the time of flight between an interaction radius (ri) and the
detection radius (rsipm).
"""
function time_of_flight(df::DataFrame, ri::Symbol, rsipm::Real, n::Real=1.6)
    cc       = SpeedOfLightInVacuum / n
    path_len = rsipm * mm .- df[!, ri]
    return uconvert.(ps, path_len ./ cc)
end


"""
    time_of_flight(df::DataFrame, source::Vector{Symbol},
                    interaction::Vector{Symbol}, n::Real)

Time of flight between two arbitrary points in a medium of refraction index n.
"""
function time_of_flight(df::DataFrame, source_xyz::Vector{Symbol},
        int_xyz::Vector{Symbol}, n::Real=1.0)
    function displacement(x1, y1, z1, x2, y2, z2)
        norm.(eachrow(hcat(x1, y1, z1) - hcat(x2, y2, z2)))
    end
    cc       = SpeedOfLightInVacuum / n
    path_len = combine(df, vcat(int_xyz, source_xyz) => displacement => :path)
    return uconvert.(ps, path_len[!, :path] ./ cc)
end


"""
    interaction_time(df::DataFrame, ri::Symbol, td::Symbol, rsipm::Real, n::Real)

Calculate the interaciton time given radius of interaction (ri) and detection time.
"""
function interaction_time(df::DataFrame, ri::Symbol, td::Symbol,
        rsipm::Real, n::Real=1.69)
    flight_time = time_of_flight(df, ri, rsipm, n)
    return uconvert.(ps, df[!, td]) .- flight_time
end


"""
    CRT(df::DataFrame, times::Vector{Symbol}, radii::Vector{Symbol}, det_rad::Real)

Calculate the difference between the calculated and expected interaction
time differences.
"""
#TODO: Protections for which symbols valid?
function CRT(df::DataFrame, times::Vector{Symbol},
        radii::Vector{Symbol}, det_rad::Real, n::Real=1.69)::Vector{<:Real}
    int1_flight = time_of_flight(df, [:xs, :ys, :zs], [:xt1, :yt1, :zt1])
    int2_flight = time_of_flight(df, [:xs, :ys, :zs], [:xt2, :yt2, :zt2])
    true_dt     = int2_flight ./ ps .- int1_flight ./ ps

    int1_det    = interaction_time(df, radii[1], times[1], det_rad, n)
    int2_det    = interaction_time(df, radii[2], times[2], det_rad, n)
    calc_dt     = int2_det ./ ps .- int1_det ./ ps

    return calc_dt - true_dt
end
