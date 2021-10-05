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
	gline2p(x1,y1,x2, y2)
	Line that goes through two points
"""
function gline2p(x1, y1, x2, y2)
    fxy(x) = y1 + (x - x1) * (y2 - y1)/(x2 -x1)
end

function gline2p(x1::Real, y1::Real, x2::Real, y2::Real)
    fxy(x::Real) = y1 + (x - x1) * (y2 - y1)/(x2 -x1)
end

"""
function wstd(x::Vector{<:Real}, q::Vector{<:Real})

Compute the std deviation in x weighted by q:
Sqrt(1/Q Sum_i (x - x_mean) * qi )
"""
function wstd(x::Vector{<:Real}, q::Vector{<:Real})
	xmean = mean(x)
	qs = sum((x.-xmean).^2 .* q)
	Q = sum(q)
	return sqrt(qs/Q)
end


"""
	mean_std(x, xmin, xmax)
	Returns mean and std for a vector x in the interval between xmin and xmax
"""
function mean_std(x::Vector{<:Real}, xmin::Real, xmax::Real)
    xx = in_range(x, xmin, xmax)
    xm = mean(xx)
    xs = StatsBase.std(xx)
    return xm, xs
end
