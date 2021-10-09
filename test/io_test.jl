@testset "io" begin
    fname = "testdata/n3-window-1m-LXe-20mm-1-5.h5"
    pdf   = read_abc(fname)

    @test length(pdf.volume_names ) ==    88
    @test length(pdf.process_names) ==     3
    @test nrow(pdf.sensor_xyz     ) == 47428
    @test ncol(pdf.sensor_xyz     ) ==     4
    @test nrow(pdf.primaries      ) ==     5
    @test ncol(pdf.primaries      ) ==     7
    @test nrow(pdf.vertices       ) ==     5
    @test ncol(pdf.vertices       ) ==    13
    @test nrow(pdf.total_charge   ) ==  1080
    @test ncol(pdf.total_charge   ) ==     3
    @test nrow(pdf.waveform       ) ==  8098
    @test ncol(pdf.waveform       ) ==     3

    evt_range = in(4995000:4995004)
    @test all(evt_range.(pdf.primaries.event_id))
    @test all(evt_range.(pdf.vertices.event_id))
    @test all(evt_range.(pdf.waveform.event_id))

    @test sum(pdf.total_charge.charge) == 8098
    
end
