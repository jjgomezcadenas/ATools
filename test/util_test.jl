using DataFrames

df = DataFrame("event_id" => [1,2,3,4,5],
               "index" => [10,20,30,40,50],
               "data" => [100.,200.,300.,400.,500.])

@testset "util" begin
    x = collect(1:100)
    y = collect(6:9)
    ## Tests for in_range function
    xr = ATools.in_range(x, 5, 10) # interval is ( )

    @test all(y .== xr)
    @test all(ATools.in_range(x, 5, 10, ATools.ClosedBound) .== collect(5:10))
    @test all(ATools.in_range(x, 5, 10, ATools.LeftClosed ) .== collect(5:9 ))
    @test all(ATools.in_range(x, 5, 10, ATools.RightClosed) .== collect(6:10))

    @test nrow(ATools.select_values(df, x -> x < 5, "event_id")) == 4
    @test ATools.select_by_index(df,
    "index", 1) == ATools.select_by_column_value(df, "index", 1)

    df3 = ATools.select_event(df, 3)
    @test df3.index[1] == 30
    @test df3.data[1] == 300.0
    @test ATools.select_by_column_value(df, "data", 100.0).index[1]==10
    @test ATools.select_by_column_value_lt(df, "data", 200.0).index[1]==10
    @test ATools.select_by_column_value_gt(df, "data", 400.0).index[1] == 50
    @test ATools.select_by_column_value_interval(df, "data", 200.0, 400.0).index[1] ==30

    @test ATools.find_max_xy(df, "event_id", "data") == (5, 5, 500.0)
end