using DataFrames
using Unitful
using PhysicalConstants.CODATA2018

@testset "reco" begin
    data_file = "testdata/evtPar_example.h5"

    _, rmin, rmax, evtdf = read_evtpar([data_file])

    # Single xy calculation
    first_evt = first(evtdf)
    x1, y1 = ATools.calculate_xy(first_evt.xr1, first_evt.yr1, first_evt.r1)
    @test isapprox(x1, first_evt.x1)
    @test isapprox(y1, first_evt.y1)

    # With broadcasting
    xv, yv, zv = ATools.radial_correction(evtdf.xr1, evtdf.yr1, evtdf.zr1, evtdf.r1)
    @test all(isapprox.(zv, evtdf.zr1))
    @test all(isapprox.(xv, evtdf.x1))
    @test all(isapprox.(yv, evtdf.y1))

    # Interaction radius.
    const_val, lin_val, bias = 373.80, -1.22, -0.13
    rad_pred = ATools.predict_interaction_radius(ATools.gpol1([const_val, lin_val]),
                                                 rmin, rmax, bias)
    transform!(evtdf, :zstd1 => rad_pred => :r1x, :zstd2 => rad_pred => :r2x)
    r1_test = const_val .+ first(evtdf.zstd1, 5) .* lin_val .+ bias
    r2_test = const_val .+ first(evtdf.zstd2, 5) .* lin_val .+ bias
    @test all(isapprox.(r1_test, first(evtdf.r1x, 5)))
    @test all(isapprox.(r2_test, first(evtdf.r2x, 5)))

    # Units conversion
    units_evtdf = ATools.set_units(evtdf)
    r1_type     = eltype(units_evtdf.r1)
    t1_type     = eltype(units_evtdf.t1)
    @test      r1_type  <: Unitful.Length
    @test      t1_type  <: Unitful.Time
    @test unit(r1_type) == Unitful.mm
    @test unit(t1_type) == Unitful.ns

    # Time of flight
    flight_time_r = ATools.time_of_flight(units_evtdf, :r1, rmax)
    @test      eltype(flight_time_r)  <: Unitful.Time
    @test unit(eltype(flight_time_r)) == Unitful.ps
    full_width_ps = uconvert(Unitful.ps, (rmax - rmin) * Unitful.mm * 1.6 / SpeedOfLightInVacuum)
    @test all(flight_time_r .<= full_width_ps)

    flight_time_disp = ATools.time_of_flight(units_evtdf, [:xs, :ys, :zs], [:x1, :y1, :z1])
    @test      eltype(flight_time_disp)  <: Unitful.Time
    @test unit(eltype(flight_time_disp)) == Unitful.ps
    expected_first6 = [ 988.117 * Unitful.ps, 1318.657 * Unitful.ps,
                        900.190 * Unitful.ps, 1029.788 * Unitful.ps,
                       1097.411 * Unitful.ps, 1210.753 * Unitful.ps]
    @test all(isapprox.(expected_first6, first(flight_time_disp, 6), atol=0.0005 * Unitful.ps))
end