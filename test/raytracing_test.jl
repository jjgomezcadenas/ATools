using LinearAlgebra
@testset "raytracing" begin
    c = ATools.Cylinder(1.0, 0.0, 1.0) 
    r1 = ATools.Ray([0.0,0.0,0.5],[0.0,1.0,0.0])

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
    t, p = ATools.propagate(r1, c)
    @test t == 1.0
    @test p == [0.0, 1.0, 0.5]
   
    r2 = ATools.Ray([0.0,0.0,0.25],[sin(π/4.0),cos(π/4.0),0.0])
    t, p = ATools.propagate(r2, c)
    @test t == 1.0
    @test p[1] ≈ p[2]
    @test p[3] ≈ 0.25

    c = ATools.Cylinder(5.0, -100.0, 100.0) 
    r = ATools.Ray([0.0,0.0,0.0],[sin(π/2.0),0.0,0.0])
    t, p = ATools.propagate(r, c)
    @test t == 5.0
    @test (p[1] ≈ 5.0 && p[2] ≈ 0.0 && p[3] ≈ 0.0)
    r = ATools.Ray([0.0,0.0,0.0],[sin(π/4.0),0.0,0.0])
    t, p = ATools.propagate(r, c)
    @test t > 5.0
    @test (p[1] ≈ 5.0 && p[2] ≈ 0.0 && p[3] ≈ 0.0)
    r = ATools.Ray([0.0,0.0,0.0],[sin(π/8.0),0.0,0.0])
    t, p = ATools.propagate(r, c)
    @test t > 10.0
    @test (p[1] ≈ 5.0 && p[2] ≈ 0.0 && p[3] ≈ 0.0)
    
end
