using LsqFit

@testset "fits" begin
    pol1(x,a,b) = a + b * x
    pol2(x, a, b, c) = a + b*x + c*x^2
    pol3(x, a, b, c, d) = a + b*x + c*x^2 + d*x^3

    x=collect(LinRange(0., 10., 100))
    y = pol1.(x,(10.0,), (3.0,),)
    fr = ATools.fit_pol1(x,y)
    @test fr.fitpar[1]≈10.0 && fr.fitpar[2] ≈ 3.0

    y = pol2.(x,(10.0,), (0.5,), (1.,),)
    fr = ATools.fit_pol2(x,y)
    @test fr.fitpar[1]≈10.0 && fr.fitpar[2] ≈ 0.5 && fr.fitpar[3] ≈ 1.0

    y = pol3.(x,(10.0,), (1.0,), (0.7,),(0.5,))
    fr = ATools.fit_pol3(x,y)
    @test fr.fitpar[1]≈10.0 && fr.fitpar[2] ≈ 1.0 && fr.fitpar[3] ≈ 0.7 && fr.fitpar[4] ≈ 0.5

    hg1,pg1 = ATools.hist1d(qs, "gaussian μ=100, σ=10",  50, 50.0, 150.0, norm=true)
    fg = ATools.fit_gauss(hg1)
    @test fg.mu[1] > 99.5 && fg.mu[1] < 100.5
    @test fg.std[1] > 9.5 && fg.std[1] < 10.5

    fr, p1 = ATools.fit_profile(xs, qs, "x", "y", "pol1")
    fpars = fr.fitpar
    fstds = fr.fitstd
    par =[100.0, 0.0]
    @test all([fpars[i] - 5* fstds[i] < par[i] for i in 1:2])

    ## Test cfit with errors using pol3 values above.
    err_sigma = 0.04
    y += rand(Normal(0, err_sigma), length(y))
    p0 = [10.0, 1.0, 0.7, 0.5]
    lb = fill( 0.0, length(p0))
    ub = fill(20.0, length(p0))
    pol3_fit = @. pol(x, p) = p[1] + p[2] * x + p[3] * x^2 + p[4] * x^3
    fit_result = ATools.func1dfit(pol3_fit, x, y, fill(err_sigma, length(y)), p0, lb, ub)
    @test fit_result.converged
    @test all(isapprox.(coef(fit_result), p0; atol=err_sigma))
end
