using GridGraphs
using Documenter

DocMeta.setdocmeta!(GridGraphs, :DocTestSetup, :(using GridGraphs); recursive=true)

makedocs(;
    modules=[GridGraphs],
    authors="Guillaume Dalle",
    sitename="GridGraphs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        repolink="https://github.com/gdalle/GridGraphs.jl/",
        canonical="https://gdalle.github.io/GridGraphs.jl",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/gdalle/GridGraphs.jl", devbranch="main")
