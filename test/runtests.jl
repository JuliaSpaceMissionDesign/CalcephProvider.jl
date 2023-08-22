using CalcephEphemeris
using CALCEPH
using Test 

using LazyArtifacts 

import JSMDInterfaces.Ephemeris as jEphem

@testset "Download all artifacts" begin
    @info artifact"testdata"
    @info "All artifacts downloaded"
end;


@testset "CalcephEphemeris.jl" begin     

    DJ2000 = 2451545.0

    test_dir = artifact"testdata"

    path_de432 = joinpath(test_dir, "de432.bsp")
    path_pa421 = joinpath(test_dir, "pa421.bpc")

    de432 = CalcephProvider(path_de432)
    pa421 = jEphem.load(CalcephProvider, path_pa421)

    kern = jEphem.load(CalcephProvider, [path_pa421, path_de432])

    points = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 199, 299, 301, 399]
    axes = [1, 31006]

    # CALCEPH.jl files 
    ephc = Ephem(path_de432)
    epho = Ephem(path_pa421)

    # Time properties tests
    @test jEphem.ephem_timescale(de432) == 1
    @test jEphem.ephem_timescale(pa421) == 1

    @test jEphem.ephem_timespan(de432) == timespan(ephc)
    @test jEphem.ephem_timespan(pa421) == timespan(epho)

    @test jEphem.ephem_available_axes(de432) == Int64[]
    @test jEphem.ephem_available_points(pa421) == Int64[]

    @test sort(jEphem.ephem_available_axes(pa421)) == axes
    @test sort(jEphem.ephem_available_points(de432)) == points

    @test sort(jEphem.ephem_available_axes(kern)) == axes
    @test sort(jEphem.ephem_available_points(kern)) == points

    # Data records tests
    @test jEphem.ephem_position_records(pa421) == jEphem.EphemPointRecord[]
    @test jEphem.ephem_orient_records(de432) == jEphem.EphemAxesRecord[]

    prec = jEphem.ephem_position_records(de432)
    crec = CALCEPH.positionRecords(ephc)

    for (rec, recc) in zip(prec, crec) 
        @test rec.center == recc.center
        @test rec.target == recc.target
        @test rec.axes == recc.frame 
        @test rec.jd_start == recc.startEpoch 
        @test rec.jd_stop == recc.stopEpoch
    end

    orec = jEphem.ephem_orient_records(pa421)
    corec = CALCEPH.orientationRecords(epho)

    for (rec, recc) in zip(orec, corec) 
        @test rec.target == recc.target
        @test rec.axes == recc.frame 
        @test rec.jd_start == recc.startEpoch 
        @test rec.jd_stop == recc.stopEpoch
    end

    y = zeros(6)
    yc = zeros(6);

    # Point ephemeris tests
    @test_throws jEphem.EphemerisError jEphem.ephem_compute!(y, de432, 0.0, 0.0, 301, 399, 1)
    jEphem.ephem_compute!(y, de432, DJ2000, 0.0, 301, 399, 1)
    
    CALCEPH.unsafe_compute!(yc, ephc, DJ2000, 0.0, 301, 399, useNaifId+unitKM+unitSec, 1)
    @test yc ≈ y atol=1e-11 rtol=1e-11

    # Axes ephemeris tests 
    @test_throws jEphem.EphemerisError jEphem.ephem_orient!(y, pa421, 0.0, 0.0, 301, 0, 1)
    jEphem.ephem_orient!(y, pa421, DJ2000, 0.0, 31006, 0, 1)

    CALCEPH.unsafe_orient!(yc, epho, DJ2000, 0.0, 31006, useNaifId+unitRad+unitSec, 1)
    @test yc ≈ y atol=1e-11 rtol=1e-11

end;