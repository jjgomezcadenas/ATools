using DataFrames
#using LinearAlgebra
#using GLM

## Use abstract type to select range conditions
## Method inspired by https://www.juliabloggers.com/julia-dispatching-enum-versus-type/
abstract type ValueBound end
struct OpenBound   <: ValueBound end
struct ClosedBound <: ValueBound end
struct LeftClosed  <: ValueBound end
struct RightClosed <: ValueBound end


function mask_function(xmin::T, xmax::T, ::Type{OpenBound  }) where T <: Number
	x -> (x .>  xmin) .& (x .<  xmax)
end

function mask_function(xmin::T, xmax::T, ::Type{ClosedBound}) where T <: Number
	x -> (x .>= xmin) .& (x .<= xmax)
end

function mask_function(xmin::T, xmax::T, ::Type{LeftClosed }) where T <: Number
	x -> (x .>= xmin) .& (x .<  xmax)
end

function mask_function(xmin::T, xmax::T, ::Type{RightClosed}) where T <: Number
	x -> (x .>  xmin) .& (x .<= xmax)
end


"""
	swap(x1::T, x2::T, cond::Bool) where T
	swaps x and y if cond is false
"""
function swap(x1::T, x2::T, cond::Bool) where T
    if cond
        return x1, x2
    else
        return x2, x1
    end
end

# Vector and data frames

"""
	in_range(x, xmin, xmax)

Given vector x, select values between xmin and xmax
"""
function in_range(x::Vector{T}, xmin::T, xmax::T,
				  interval::Type{S}=OpenBound) where {T <: Number, S <: ValueBound}
    return x[mask_function(xmin, xmax, interval)(x)]
end


"""
	select_values

Generic function to get values in a DataFrame given a condition
function.
TODO: Is it possible to specify that cond must take Vector and return Bool?
"""
function select_values(dbdf::DataFrame, cond_func::Function)
	return dbdf[cond_func(dbdf), :]
end


"""
	select_event(dbdf::DataFrame, index::Int64)

Take the event dataframe and the index of an event and returns a data frame
which selects that particular event

"""
function select_event(dbdf::DataFrame, event_id::Integer)
	return select_by_column_value(dbdf, "event_id", event_id)
end


"""
	select_by_column_value(df::DataFrame, column::String, value)

Select elements in the DF which have "value" in "column"
"""
function select_by_column_value(df::DataFrame, column::String, value)
	return select_values(df, x -> x[!, column] .== value)
end

"""
	select_by_column_value_lt(df::DataFrame, column::String, value)

Select elements in the DF which are less than "value" in "column"
"""
function select_by_column_value_lt(df::DataFrame, column::String, value)
	return select_values(df, x -> x[!, column] .< value)
end


"""
	select_by_column_value_le(df::DataFrame, column::String, value)

Select elements in the DF which are less or equal than "value" in "column"
"""
function select_by_column_value_le(df::DataFrame, column::String, value)
	return select_values(df, x -> x[!, column] .<= value)
end


"""
	select_by_column_value_gt(df::DataFrame, column::String, value)

Select elements in the DF which are larger than "value" in "column"
"""
function select_by_column_value_gt(df::DataFrame, column::String, value)
	return select_values(df, x -> x[!, column] .> value)
end


"""
	select_by_column_value_ge(df::DataFrame, column::String, value)

Select elements in the DF which are larger or equal than "value" in "column"
"""
function select_by_column_value_ge(df::DataFrame, column::String, value)
	return select_values(df, x -> x[!, column] .>= value)
end


"""
	select_by_column_value_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval (valuef, valuel)
"""
function select_by_column_value_interval(df::DataFrame, column::String, valuef, valuel)
	cond_func = d -> mask_function(valuef, valuel, OpenBound)(d[!, column])
	return select_values(df, cond_func)
end


"""
	select_by_column_value_closed_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval [valuef, valuel]
"""
function select_by_column_value_closed_interval(df::DataFrame, column::String, valuef, valuel)
	cond_func = d -> mask_function(valuef, valuel, ClosedBound)(d[!, column])
	return select_values(df, cond_func)
	#return df[mask_function(df[!, column], valuef, valuel, ClosedBound), :]
end


"""
	select_by_column_value_closed_left_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval [valuef, valuel)
"""
function select_by_column_value_closed_left_interval(df::DataFrame, column::String, valuef, valuel)
	cond_func = d -> mask_function(valuef, valuel, LeftClosed)(d[!, column])
	return select_values(df, cond_func)
	#return df[mask_function(df[!, column], valuef, valuel, LeftClosed), :]
end


"""
	select_by_column_value_closed_right_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval (valuef, valuel]
"""
function select_by_column_value_closed_right_interval(df::DataFrame, column::String, valuef, valuel)
	cond_func = d -> mask_function(valuef, valuel, RightClosed)(d[!, column])
	return select_values(df, cond_func)
	#return df[mask_function(df[!, column], valuef, valuel, RightClosed), :]
end



"""
	select_by_index(df::DataFrame, column::String, value::Integer)

Select elements in the DF which have "value" (Integer) in "column"
!Name is misleading, does not select by index.
"""
function select_by_index(df::DataFrame, column::String, value::Integer)
	return select_by_column_value(df, column, value)
end



""""
	find_max_xy(df, xc, yc)

Return ymax and x such that ymax = f(x).

**Description:**

In a DataFrame one has often "XY" variables, that is, a pair of columns
"X" and "Y" which represent correlated variables (e.g intensity and wavelength).
In such cases one often wants the XY maximum, that is, finding the maximum
of "Y" (call it ymax) and the corresponding value in "X"
(x for which y is ymax). This corresponds, for example, to the wavelength at
which the intensity is maximal.


**Arguments:**
- `df::DataFrame`: data frame holding the data.
- `xc::String`: the X column.
- `yc::String`: the Y column.
"""
##!! The two functions here have the same name but
##   one gives the index and x, y where y maximal
##   and the other index and x, y where x maximal
##   This behaviour seems unstable.
function find_max_xy(df::DataFrame, xc::String, yc::String)
	ymax, imax = findmax(df[!, yc])
	x_ymax = df[imax, xc]
	return ymax, x_ymax
end

## Different functionality to above with same name?
function find_max_xy(x::Vector{T}, y::Vector{T}) where T
	ymax, imax = findmax(x)
	x_ymax = y[imax]
	return ymax, imax, x_ymax
end
