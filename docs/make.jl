using CalcephProvider 
using Documenter 

makedocs(;
    authors="Julia Space Mission Design Development Team",
    sitename="CalcephProvider.jl",
    modules=[CalcephProvider],
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(; 
    repo = "github.com/JuliaSpaceMissionDesign/CalcephProvider.jl",
    branch = "gh-pages",
)