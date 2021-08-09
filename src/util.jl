using DataFrames
#using LinearAlgebra
#using GLM


# Vector and data frames


"""
	select_event(dbdf::DataFrame, index::Int64)

Take the event dataframe and the index of an event and returns a data frame
which selects that particular event

"""
function select_event(dbdf::DataFrame, index::Integer)
	return select_by_index(dbdf, "event_id", index)[:,2:end]
end

"""
	select_by_column_value(df::DataFrame, column::String, value)

Select elements in the DF which have "value" in "column"
"""
function select_by_column_value(df::DataFrame, column::String, value)
	mask = df[!,column].==value
	return df[mask,:]
end

"""
	select_by_column_value_lt(df::DataFrame, column::String, value)

Select elements in the DF which are less than "value" in "column"
"""
function select_by_column_value_lt(df::DataFrame, column::String, value)
	mask = df[!,column].<value
	return df[mask,:]
end


"""
	select_by_column_value_le(df::DataFrame, column::String, value)

Select elements in the DF which are less or equal than "value" in "column"
"""
function select_by_column_value_le(df::DataFrame, column::String, value)
	mask = df[!,column].<=value
	return df[mask,:]
end


"""
	select_by_column_value_gt(df::DataFrame, column::String, value)

Select elements in the DF which are larger than "value" in "column"
"""
function select_by_column_value_gt(df::DataFrame, column::String, value)
	mask = df[!,column].>value
	return df[mask,:]
end


"""
	select_by_column_value_ge(df::DataFrame, column::String, value)

Select elements in the DF which are larger or equal than "value" in "column"
"""
function select_by_column_value_ge(df::DataFrame, column::String, value)
	mask = df[!,column].>=value
	return df[mask,:]
end


"""
	select_by_column_value_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval (valuef, valuel)
"""
function select_by_column_value_interval(df::DataFrame, column::String, valuef, valuel)
	df1 = select_by_column_value_gt(df, column, valuef)
    return select_by_column_value_lt(df1, column, valuel)
end


"""
	select_by_column_value_closed_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval [valuef, valuel]
"""
function select_by_column_value_closed_interval(df::DataFrame, column::String, valuef, valuel)
	df1 = select_by_column_value_ge(df, column, valuef)
    return select_by_column_value_le(df1, column, valuel)
end


"""
	select_by_column_value_closed_left_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval [valuef, valuel)
"""
function select_by_column_value_closed_left_interval(df::DataFrame, column::String, valuef, valuel)
	df1 = select_by_column_value_ge(df, column, valuef)
    return select_by_column_value_lt(df1, column, valuel)
end


"""
	select_by_column_value_closed_right_interval(df::DataFrame, column::String, valuef, valuel)

Select elements in the DF which are in interval (valuef, valuel]
"""
function select_by_column_value_closed_right_interval(df::DataFrame, column::String, valuef, valuel)
	df1 = select_by_column_value_gt(df, column, valuef)
    return select_by_column_value_le(df1, column, valuel)
end



"""
	select_by_index(df::DataFrame, column::String, value::Integer)

Select elements in the DF which have "value" (Integer) in "column"

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
function find_max_xy(df::DataFrame, xc::String, yc::String)
	ymax, imax = findmax(df[!, yc])
	x_ymax = df[imax, xc]
	return ymax, x_ymax
end
