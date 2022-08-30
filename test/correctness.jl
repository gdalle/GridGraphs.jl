using ForwardDiff
using Graphs
using GridGraphs
using GridGraphs: rook, queen, cyclic, acyclic, direct, corner
using Random
using Test

Random.seed!(63)

h = 13
w = 21
T = Int32
R = Float32

weights_matrix = rand(R, h, w);
active = fill(false, h, w);
active[1, :] .= true;
active[h, :] .= true;
active[:, 1] .= true;
active[:, w] .= true;

W = typeof(weights_matrix)
A = typeof(active)

graphs_to_test = GridGraph[]
for mt in (rook, queen), md in (cyclic, acyclic), mc in (direct, corner)
    push!(graphs_to_test, FullGridGraph{T,R,W,mt,md,mc}(weights_matrix))
    push!(graphs_to_test, SparseGridGraph{T,R,W,A,mt,md,mc}(weights_matrix, active))
end

for g in graphs_to_test
    s = one(T)
    d = nv(g)
    test_name = string(typeof(g))
    @testset verbose = true "$test_name" begin
        @testset verbose = true "Interface" begin
            @test eltype(g) == T
            @test edgetype(g) == Edge{T}
            @test is_directed(g)
            @test is_directed(typeof(g))

            @test GridGraphs.height(g) == h
            @test GridGraphs.width(g) == w

            @test nv(g) == h * w
            @test typeof(nv(g)) == T
            @test length(vertices(g)) == nv(g)

            @test all(has_vertex(g, v) for v in vertices(g))
            @test !has_vertex(g, nv(g) + 1)

            @test ne(g) == length(collect(edges(g)))
            @test all(has_edge(g, src(ed), dst(ed)) for ed in edges(g))
            @test !has_edge(g, 1, 1)

            @test [
                GridGraphs.coord_to_index(g, i, j) for j in 1:GridGraphs.width(g) for
                i in 1:GridGraphs.height(g)
            ] == 1:nv(g)
            @test [GridGraphs.index_to_coord(g, v) for v in vertices(g)] == [(i, j) for j in 1:GridGraphs.width(g) for i in 1:GridGraphs.height(g)]
        end

        @testset verbose = true "Shortest paths" begin
            spt_ref = Graphs.dijkstra_shortest_paths(g, s)
            spt1 = grid_dijkstra(g, s)
            spt2 = grid_bellman_ford(g, s)
            @test spt1.dists[d] ≈ spt_ref.dists[d]
            @test spt2.dists[d] ≈ spt_ref.dists[d]
            @test min(h, w) <= length(get_path(spt1, s, d)) <= h * w
            @test min(h, w) <= length(get_path(spt2, s, d)) <= h * w
            if GridGraphs.move_direction(g) == acyclic
                spt3 = grid_topological_sort(g, s)
                @test spt3.dists[d] ≈ spt_ref.dists[d]
                @test min(h, w) <= length(get_path(spt3, s, d)) <= h * w
            end
        end

        @testset verbose = true "Type stability" begin
            @inferred grid_dijkstra(g, s, d)
            @inferred grid_bellman_ford(g, s, d)
            if GridGraphs.move_direction(g) == acyclic
                @inferred grid_topological_sort(g, s, d)
            end
        end
    end
end

@testset verbose = true "ForwardDiff" begin
    ∇1 = ForwardDiff.gradient(weights_matrix) do wm
        g = FullAcyclicGridGraph(wm)
        grid_topological_sort(g, 1).dists[end]
    end

    ∇2 = ForwardDiff.gradient(weights_matrix) do wm
        g = FullAcyclicGridGraph(wm)
        grid_dijkstra(g, 1).dists[end]
    end

    ∇3 = ForwardDiff.gradient(weights_matrix) do wm
        g = FullAcyclicGridGraph(wm)
        grid_bellman_ford(g, 1).dists[end]
    end

    @test ∇1 == ∇2
    @test ∇1 == ∇3
end

g = graphs_to_test[2]

collect(edges(g))

s = 67
d = 66

Edge(s, d) in collect(edges(g))

has_edge(g, s, d)

outneighbors(g, s) |> collect

d in outneighbors(g, s)

is, js = GridGraphs.index_to_coord(g, s)
id, jd = GridGraphs.index_to_coord(g, d)

Δi, Δj = id - is, jd - js

abs(Δi) + abs(Δj)

GridGraphs.active_vertex_coord(g, is, js)
GridGraphs.active_vertex_coord(g, id, jd)

has_vertex(g, s)
has_vertex(g, d)

GridGraphs.has_edge_coord(g, is, js, id, jd)
