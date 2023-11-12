module CalcephEphemeris

export CalcephProvider,
    load, 
    ephem_compute!,
    ephem_orient!, 
    ephem_position_records, 
    ephem_orient_records

using CALCEPH_jll: libcalceph

import JSMDInterfaces.Ephemeris as jEph

include("internals.jl")
include("interfaces.jl")

end
