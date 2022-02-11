using DataFrames
using StatsBase


"""
	rxy(x::Real,y::Real)
	r -> sqrt{x^2 + y^2}
"""
function rxy(x::Real, y::Real)
    return sqrt(x^2 + y^2)
end


"""
	hixy(x::Real, y::Real)
	phi -> atan(y/x)
"""
function phixy(x::Real, y::Real)
    return atan(y,x)
end

"""
	phixy(hitdf::DataFrame)
	phi -> atan(y/x) where y and x are columns of the data frame
"""
function fphi(hitdf::DataFrame)
    return atan.(hitdf.y,hitdf.x)
end


"""
	dxyz(x1::Vector{<:Real}, x2::Vector{<:Real})

Distance between two points.
"""
function dxyz(x1::Vector{<:Real}, x2::Vector{<:Real})
    return sqrt((x1[1] - x2[1])^2 + (x1[2] - x2[2])^2 + (x1[3] - x2[3])^2)
end


"""
	gline2p(x1::Real, y1::Real, x2::Real, y2::Real)
	Return function of a line that goes through (x1, y1), (x2, y2)
"""
function gline2p(x1::Real, y1::Real, x2::Real, y2::Real)
    fxy(x::Real) = y1 + (x - x1) * (y2 - y1)/(x2 -x1)
end


"""
	mean_std(x::Vector{T}, xmin::T=typemin(T), xmax::T=typemax(T);
	         w::Union{Nothing, Vector{T}}=nothing) where T
Returns mean and std of a vector x in the interval between xmin and xmax.
Using weights w if requested.
"""
function mean_std(x::Vector{T}, xmin::T=typemin(T), xmax::T=typemax(T);
	              w::Union{Nothing, Vector{T}}=nothing) where T
	mask = broadcast(range_bound(xmin, xmax, ATools.OpenBound), x)
    xx   = x[mask]
	if isnothing(w)
		ww = ones(eltype(xx), length(xx))
	else
		ww = w[mask]
	end
    return mean_and_std(xx, FrequencyWeights(ww), corrected=true)
end
