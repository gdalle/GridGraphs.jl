using Aqua
using GridGraphs
using JuliaFormatter
using Test

@testset verbose = true "GridGraphs.jl" begin
    @testset verbose = true "Code quality (Aqua)" begin
        Aqua.test_all(GridGraphs; ambiguities=false)
    end
    @testset verbose = true "Code formatting (JuliaFormatter)" begin
        @test format(GridGraphs; verbose=false, overwrite=false)
    end
    @testset verbose = true "Correctness" begin
        include("correctness.jl")
    end
    @testset verbose = true "Autodiff" begin
        include("autodiff.jl")
    end
end
