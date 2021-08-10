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
    xr = ATools.in_range(x, 5, 10) # interval is [ )

    @test all(y .== xr)
    @test all(Float32.(y) .== Float32.(xr))
    @test all(Float64.(y) .== Float64.(xr))

    @test ATools.rxy(1,1) ≈ sqrt(2.)
    @test ATools.phixy(1,1) ≈ π/4

    @test ATools.dxyz([1,1,1], [2,2,2]) ≈ sqrt(3.)

    
    qs = ones(length(data))
    @test isapprox(ATools.wstd(data, qs), std(data), rtol=1e-4)

    m,s = ATools.mean_std(x, 5, 10)
    @test m ≈ mean(y)
    @test s ≈ std(y)
end

@testset "util" begin
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
    #println(ic)
    #println(hc[ic])
    @test hc[ic] > 99.0 && hc[ic] < 101.0
    
    h2 = ATools.hist1d(qs, 25, 50.0, 150.0, true)
    h2n = ATools.hist1d(qs, 25, 50.0, 150.0, false)
    ic = argmax(h2.weights)
    r = h2n.weights[ic] / h2.weights[ic]  # area of bins (bin[i+1] - bin[1]) = 4
    #println(r)
    @test r == 4.0

    p1df, p = ATools.p1df(xs, qs, 25)
    @test (mean(p1df.y_mean) > 99.0 && mean(p1df.y_mean) < 101.0)
    @test (mean(p1df.x_mean) > 0.4 && mean(p1df.x_mean) < 0.6)
    @test (mean(p1df.y_std) > 9.0 && mean(p1df.y_std) < 11.0)


end

