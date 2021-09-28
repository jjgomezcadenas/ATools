using ATools
using Test
using Distributions
using Statistics


qx = Normal(100.0, 10.0)
qs = rand(qx, 100000)
dx = Normal(100.0, 5.0)
data = rand(dx, 100000)
xs=rand(Float64, length(qs))

#include("math_test.jl")
#include("util_test.jl")
#include("histos_test.jl")
#include("fits_test.jl")
include("raytracing_test.jl")
