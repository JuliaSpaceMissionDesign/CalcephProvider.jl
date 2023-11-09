# CalcephEphemeris.jl API

_A lightweight CALCEPH.jl wrapper for the JSMD ecosystem._ 

This package is a lightweight wrapper around [CALCEPH_jll.jl](https://github.com/JuliaBinaryWrappers/CALCEPH_jll.jl) that implements the [JSMDInterfaces.jl](https://github.com/JuliaSpaceMissionDesign/JSMDInterfaces.jl) interfaces to extract data from SPICE and INPOP ephemeris kernels. 

The CALCEPH is a C++ library written by the research team Astronomie et systèmes dynamiques 
(CNRS/Observatoire de Paris/IMCCE). For further information on CALCEPH visit its 
[official website](https://www.imcce.fr/inpop/calceph). Inspiration for this package has been taken from the original Julia's [CALCEPH.jll](https://github.com/JuliaAstro/CALCEPH_jll.jl)  wrapper.


## Installation 

This package can be installed using Julia's package manager:

```julia
julia> import Pkg; 

julia> Pkg.add("CalcephEphemeris.jl")
```