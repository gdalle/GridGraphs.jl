using Aqua
using GridGraphs
using JuliaFormatter
using Test

@testset verbose = true "GridGraphs.jl" begin
    @testset "Code quality" begin
        Aqua.test_all(GridGraphs; ambiguities=false)
    end
    @testset "Code formatting" begin
        @test format(GridGraphs; verbose=false, overwrite=false)
    end
    @testset verbose = true "Correctness" begin
        include("correctness.jl")
    end
end
