using CalcephEphemeris 
using Documenter 

makedocs(;
    authors="Julia Space Mission Design Development Team",
    sitename="CalcephEphemeris.jl",
    modules=[CalcephEphemeris],
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(; 
    repo = "github.com/JuliaSpaceMissionDesign/CalcephEphemeris.jl",
    branch = "gh-pages",
)