using Aqua
using GridGraphs
using JET
using JuliaFormatter
using Test

@testset verbose = true "GridGraphs.jl" begin
    @testset "Code quality (Aqua)" begin
        Aqua.test_all(GridGraphs; ambiguities=false)
    end
    @testset "Code formatting (JuliaFormatter)" begin
        @test JuliaFormatter.format(GridGraphs; verbose=false, overwrite=false)
    end
    @testset "Code linting (JET)" begin
        JET.test_package(GridGraphs; target_defined_modules=true)
    end
    @testset "Correctness" begin
        include("correctness.jl")
    end
end
