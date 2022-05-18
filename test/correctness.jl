using BenchmarkTools
using Graphs
using GridGraphs
using Test

h = 13
w = 21
T = Int32
R = Float32

weights = rand(R, h, w);
full_mask = ones(Bool, h, w);
partial_mask = zeros(Bool, h, w);
partial_mask[1, :] .= true;
partial_mask[h, :] .= true;
partial_mask[:, 1] .= true;
partial_mask[:, w] .= true;

for g in [
    GridGraph{T,R}(weights),
    AcyclicGridGraph{T,R}(weights),
    SparseGridGraph{T,R}(weights, full_mask),
    SparseGridGraph{T,R}(weights, partial_mask),
]
    if g isa SparseGridGraph
        is_full = sum(g.mask) == prod(size(g.mask))
        test_name = is_full ? "$(typeof(g)) - full" : "$(typeof(g)) - sparse"
    else
        test_name = "$(typeof(g))"
    end
    @testset verbose = true "$test_name" begin
        # Graphs interface

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
            GridGraphs.node_index(g, i, j) for j in 1:GridGraphs.width(g) for
            i in 1:GridGraphs.height(g)
        ] == 1:nv(g)
        @test [GridGraphs.node_coord(g, v) for v in vertices(g)] == [(i, j) for j in 1:GridGraphs.width(g) for i in 1:GridGraphs.height(g)]

        # Shortest paths

        s = one(T)
        d = nv(g)

        @test grid_dijkstra(g, s; naive=false).dists[d] ≈
            Graphs.dijkstra_shortest_paths(g, s).dists[d]
        @test grid_dijkstra(g, s; naive=true).dists[d] ≈
            Graphs.dijkstra_shortest_paths(g, s).dists[d]

        @test min(h, w) <= length(grid_dijkstra(g, s, d; naive=false)) <= h * w
        @test min(h, w) <= length(grid_dijkstra(g, s, d; naive=true)) <= h * w

        if GridGraphs.is_acyclic(g)
            @test grid_topological_sort(g, s).dists[d] ≈
                Graphs.dijkstra_shortest_paths(g, s).dists[d]
            @test min(h, w) <= length(grid_topological_sort(g, s, d)) <= h * w
        else
            @test Graphs.dijkstra_shortest_paths(g, s).dists[d] ==
                Graphs.dijkstra_shortest_paths(reverse(g), s).dists[d]
        end
    end
end
