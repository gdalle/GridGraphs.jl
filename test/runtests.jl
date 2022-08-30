using Aqua
using Documenter
using GridGraphs
using Test

@testset verbose = true "GridGraphs.jl" begin
    @testset verbose = true "Code quality (Aqua)" begin
        Aqua.test_all(GridGraphs, ambiguities=false)
    end
    @testset verbose = true "Doctests" begin
        doctest(GridGraphs)
    end
    @testset verbose = true "Correctness" begin
        include("correctness.jl")
    end
end
