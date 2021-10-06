@testset "io" begin
    ## TODO: Need small, reliable testset.
    fname = "testdata/test_simout.h5"
    pdf   = read_abc(fname)

    @test length(pdf.volume_names ) == 88
    @test length(pdf.process_names) ==  3
    @test nrow(pdf.sensor_xyz  ) ==    47428
    @test ncol(pdf.sensor_xyz  ) ==        4
    @test nrow(pdf.primaries   ) ==     5000
    @test ncol(pdf.primaries   ) ==        7
    @test nrow(pdf.vertices    ) ==    14446
    @test ncol(pdf.vertices    ) ==       13
    @test nrow(pdf.total_charge) ==  2410844
    @test ncol(pdf.total_charge) ==        3
    @test nrow(pdf.waveform    ) == 18900366
    @test ncol(pdf.waveform    ) ==        3
end
