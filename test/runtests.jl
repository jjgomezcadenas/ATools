using ATools
using Test
using Distributions
using Statistics
using DataFrames

df = DataFrame("event_id" => [1,2,3,4,5],
               "index" => [10,20,30,40,50],
               "data" => [100.,200.,300.,400.,500.])

qx = Normal(100.0, 10.0)
qs = rand(qx, 100000)
dx = Normal(100.0, 5.0)
data = rand(dx, 100000)
xs=rand(Float64, length(qs))

include("math_test.jl")
include("util_test.jl")
include("histos_test.jl")
include("fits_test.jl")