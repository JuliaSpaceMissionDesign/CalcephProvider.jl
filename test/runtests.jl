using CalcephEphemeris
using Test 

using Tempo
using SPICE
import JSMDInterfaces.Ephemeris as jEphem

@testset "CalcephEphemeris.jl" begin     
    
    # Write your tests here.
    furnsh(pwd()*"/test/assets/de432s.bsp")

    eph = CalcephProvider(pwd()*"/test/assets/de432s.bsp")
    @test jEphem.ephem_timescale(eph) == 1

    # y = zeros(3)
    # @test jEphem.ephem_compute!(y, eph, DJ2000, 0.0, 301, 399, 0)

    kclear()

end