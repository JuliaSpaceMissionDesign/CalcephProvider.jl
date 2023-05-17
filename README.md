# CalcephEphemeris.jl 

_A lightweight CALCEPH.jl wrapper for the JSMD ecosystem._ 

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaspacemissiondesign.github.io/CalcephEphemeris.jl/stable/) 
[![Dev Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaspacemissiondesign.github.io/CalcephEphemeris.jl/dev/) 
[![Build Status](https://github.com/JuliaSpaceMissionDesign/CalcephEphemeris.jl/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/JuliaSpaceMissionDesign/CalcephEphemeris.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/JuliaSpaceMissionDesign/CalcephEphemeris.jl/branch/main/graph/badge.svg?token=3SJCV229XX)](https://codecov.io/gh/JuliaSpaceMissionDesign/CalcephEphemeris.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This package is a lightweight wrapper around [CALCEPH.jl](https://github.com/JuliaAstro/CALCEPH.jl) that implements the [JSMDInterfaces.jl](https://github.com/JuliaSpaceMissionDesign/JSMDInterfaces.jl) interfaces to extract data from SPICE and INPOP ephemeris kernels. 

## Installation

This package can be installed using Julia's package manager: 
```julia
julia> import Pkg; 
julia> Pkg.add("CalcephEphemeris.jl")
```

## Documentation 

For further information on this package and on the CALCEPH library see the package [documentation](https://juliaspacemissiondesign.github.io/CalcephEphemeris.jl/stable/), 
the offical CALCEPH [website](https://www.imcce.fr/inpop/calceph) or its original 
[Julia wrapper](https://github.com/JuliaAstro/CALCEPH.jl) page.
