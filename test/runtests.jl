using Aqua
using GridGraphs
using JET
using JuliaFormatter
using Test

@testset verbose = true "GridGraphs.jl" begin
    @testset "Code quality" begin
        Aqua.test_all(GridGraphs; ambiguities=false)
    end
    @testset "Code formatting" begin
        @test format(GridGraphs; verbose=false, overwrite=false)
    end
    @testset "Code linting" begin
        JET.test_package(GridGraphs; target_defined_modules=true)
    end
    @testset verbose = true "Correctness" begin
        include("correctness.jl")
    end
end
