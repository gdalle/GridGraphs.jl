using GridGraphs
using Documenter

DocMeta.setdocmeta!(GridGraphs, :DocTestSetup, :(using GridGraphs); recursive=true)

makedocs(;
    modules=[GridGraphs],
    authors="Guillaume Dalle <22795598+gdalle@users.noreply.github.com> and contributors",
    repo="https://github.com/gdalle/GridGraphs.jl/blob/{commit}{path}#{line}",
    sitename="GridGraphs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://gdalle.github.io/GridGraphs.jl",
        assets=String[],
    ),
    pages=["Home" => "index.md", "API reference" => "api.md"],
)

deploydocs(; repo="github.com/gdalle/GridGraphs.jl", devbranch="main")
