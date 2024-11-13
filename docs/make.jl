using GridGraphs
using Documenter

DocMeta.setdocmeta!(GridGraphs, :DocTestSetup, :(using GridGraphs); recursive=true)

makedocs(;
    modules=[GridGraphs],
    authors="Guillaume Dalle",
    sitename="GridGraphs.jl",
    format=Documenter.HTML(),
    pages=["index.md"],
)

deploydocs(; repo="github.com/gdalle/GridGraphs.jl", devbranch="main")
