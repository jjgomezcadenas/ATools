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

    h2, _ = hist2d(xs, qs, 100, "xs", "qs")
    @test sum(h2.weights) == length(xs)
    @test length(h2.edges[1]) == size(h2.weights)[1] + 1
    max_q = argmax(sum(h2.weights, dims=2))[1]
    @test isapprox(centers(h2)[max_q], mean(qs), atol=2*step(h2.edges[1]))

    profile_nbins = 25
    p1df, _ = ATools.p1df(xs, qs, profile_nbins)
    @test (mean(p1df.y_mean) > 95.0 && mean(p1df.y_mean) < 105.0)
    @test (mean(p1df.x_mean) > 0.3 && mean(p1df.x_mean) < 0.7)
    @test (mean(p1df.y_std) > 8.0 && mean(p1df.y_std) < 12.0)

    p1df_filt, _ = ATools.p1df(xs, qs, profile_nbins, min_proportion=0.1)
    @test nrow(p1df_filt) == profile_nbins

end
