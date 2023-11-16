using Aqua
using GridGraphs
using JuliaFormatter
using Test

@testset verbose = true "GridGraphs.jl" begin
    @testset "Code quality (Aqua)" begin
        Aqua.test_all(GridGraphs; ambiguities=false)
    end
    @testset "Code formatting (JuliaFormatter)" begin
        @test format(GridGraphs; verbose=false, overwrite=false)
    end
    @testset "Correctness" begin
        include("correctness.jl")
    end
    @testset "Shortest paths" begin
        include("shortest_paths.jl")
    end
end
