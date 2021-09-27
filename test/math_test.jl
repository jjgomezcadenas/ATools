@testset "math" begin
    x = collect(1:100)
    y = collect(6:9)

    @test ATools.rxy(1,1) ≈ sqrt(2.)
    @test ATools.phixy(1,1) ≈ π/4

    @test ATools.dxyz([1,1,1], [2,2,2]) ≈ sqrt(3.)


    qs = ones(length(data))
    @test isapprox(ATools.wstd(data, qs), std(data), rtol=1e-4)

    m,s = ATools.mean_std(x, 5, 10)
    @test m ≈ mean(y)
    @test s ≈ std(y)

    fxy = ATools.gline2p(0, 10., 1., 2.)
    @test fxy(0) == 10.0
    @test fxy(1) == 2.0
    @test fxy(0.5) == 6.0
end