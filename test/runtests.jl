using ATools
using Test
using Distributions
using Statistics
using DataFrames
#using StatsModels

df = DataFrame("event_id" => [1,2,3,4,5],
               "index" => [10,20,30,40,50],
               "data" => [100.,200.,300.,400.,500.])

qx = Normal(100.0, 10.0)
qs = rand(qx, 100000)
dx = Normal(100.0, 5.0)
data = rand(dx, 100000)
xs=rand(Float64, length(qs))

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

@testset "util" begin
    x = collect(1:100)
    y = collect(6:9)
    ## Tests for in_range function
    xr = ATools.in_range(x, 5, 10) # interval is ( )

    @test all(y .== xr)
    
    @test ATools.select_by_index(df,
    "index", 1) == ATools.select_by_column_value(df, "index", 1)

    df3 = ATools.select_event(df, 3)
    @test df3.index[1] == 30
    @test df3.data[1] == 300.0
    @test ATools.select_by_column_value(df, "data", 100.0).index[1]==10
    @test ATools.select_by_column_value_lt(df, "data", 200.0).index[1]==10
    @test ATools.select_by_column_value_gt(df, "data", 400.0).index[1] == 50
    @test ATools.select_by_column_value_interval(df, "data", 200.0, 400.0).index[1] ==30

    @test ATools.find_max_xy(df, "event_id", "data") == (500.0, 5)
end

@testset "histos" begin
    x = [0.2, 6.4, 3.0, 1.6]
    bins = [0.0, 1.0, 2.5, 4.0, 10.0]
    inds = ATools.digitize(x,bins)
    @test all(inds .==[1,4,3,2])

    bins = [0,1,7] # a small and a large bin
    obs = [0.5, 1.5, 1.5, 2.5]; # one observation in the small bin and three in the large
    h  = ATools.hist1d(obs, bins, false) # not normalized
    hn = ATools.hist1d(obs, bins, true) # normalized

    he = ATools.edges(h)
    xn = [h.weights[i] / (he[i+1]- he[i]) for i in 1:length(h.weights)]
    @test all(xn .== hn.weights)

    h= ATools.hist1d(qs, 100, 50.0, 150.0)

    @test all(ATools.edges(h) .== h.edges[1])
    he = ATools.edges(h)
    hc = ATools.centers(h)
    @test hc[1] == (he[1] + he[2]) / 2.0
    @test hc[end] == (he[end-1] + he[end]) / 2.0
    ic = argmax(h.weights)
    @info "position of the maximum" ic
    @info "value of the maximum" hc[ic]
    @test hc[ic] > 95.0 && hc[ic] < 105.0

    h2 = ATools.hist1d(qs, 25, 50.0, 150.0, true)
    h2n = ATools.hist1d(qs, 25, 50.0, 150.0, false)
    ic = argmax(h2.weights)
    r = h2n.weights[ic] / h2.weights[ic]  # area of bins (bin[i+1] - bin[1]) = 4
    #println(r)
    @test r == 4.0

    p1df, p = ATools.p1df(xs, qs, 25)
    @test (mean(p1df.y_mean) > 95.0 && mean(p1df.y_mean) < 105.0)
    @test (mean(p1df.x_mean) > 0.3 && mean(p1df.x_mean) < 0.7)
    @test (mean(p1df.y_std) > 8.0 && mean(p1df.y_std) < 12.0)

end

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
end
