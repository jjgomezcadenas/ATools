using ATools
using Test
using Distributions
using Statistics
using DataFrames
using LinearAlgebra

df = DataFrame("event_id" => [1,2,3,4,5],
               "index" => [10,20,30,40,50],
               "data" => [100.,200.,300.,400.,500.])

qx = Normal(100.0, 10.0)
qs = rand(qx, 100000)
dx = Normal(100.0, 5.0)
data = rand(dx, 100000)
xs=rand(Float64, length(qs))

#include("math_test.jl")
#include("util_test.jl")
#include("histos_test.jl")
#include("fits_test.jl")

@testset "raytracing" begin
    c = ATools.Cylinder(1.0, 0.0, 1.0) 

    # check that point (1,0,0) verifies cylinder equation 
    @test ATools.cylinder_equation(c, [1.0, 0.0, 0.0]) ≈ 0.0
    @test ATools.cylinder_equation(c, [0.0, 1.0, 0.0]) ≈ 0.0
    @test isapprox(ATools.cylinder_equation(c, [1.0/sqrt(2.0), 1.0/sqrt(2.0), 0.0]), 0.0, atol=1e-9)

    # check that normal to barrel is perpendicular to z axis
    nb = ATools.normal_to_barrel(c,  [1.0, 2.0, 3.0])
    @test dot(nb,[0.0, 0.0, 1.0]) ≈ 0.0

    #check functions for unit cylinder
    @test ATools.length(c) ≈ 1.0
    @test ATools.perimeter(c) ≈ 2 * π 
    @test ATools.area_barrel(c) ≈ 2 * π 
    @test ATools.area_endcap(c) ≈ π 
    ATools.area(c) ≈ 4 * π
    ATools.volume(c) ≈ π 
end