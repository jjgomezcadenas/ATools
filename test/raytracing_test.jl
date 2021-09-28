using LinearAlgebra
@testset "raytracing" begin
    c = ATools.Cylinder(1.0, 0.0, 1.0) 
    r = ATools.Ray([0.5,0.5,0.5],[1.0,0.0,0.0])

    # check that point (1,0,0) verifies cylinder equation 
    @test ATools.cylinder_equation(c, [1.0, 0.0, 0.0]) ≈ 0.0
    @test ATools.cylinder_equation(c, [0.0, 1.0, 0.0]) ≈ 0.0
    @test isapprox(ATools.cylinder_equation(c, [1.0/sqrt(2.0), 1.0/sqrt(2.0), 0.0]), 0.0, atol=1e-9)

    # check that normal to barrel is perpendicular to z axis
    nb = ATools.normal_to_barrel(c,  [1.0, 2.0, 3.0])
    @test dot(nb,[0.0, 0.0, 1.0]) ≈ 0.0

    #check functions for unit cylinder
    @test ATools.cylinder_length(c) ≈ 1.0
    @test ATools.perimeter(c) ≈ 2 * π 
    @test ATools.area_barrel(c) ≈ 2 * π 
    @test ATools.area_endcap(c) ≈ π 
    @test ATools.area(c) ≈ 4 * π
    @test ATools.volume(c) ≈ π 

    @test ATools.in_endcaps(c, [1.,1.,0.])
    @test ATools.in_endcaps(c, [1.,1.,1.]) 
    println(ATools.intersection_roots(r, c))
end
