using Graphs
using GridGraphs
using Test

h = 50
w = 100
T = Int32
R = Float32

for g in [GridGraph{T,R}(rand(R, h, w)), AcyclicGridGraph{T,R}(rand(R, h, w))]
    @testset verbose = true "$(typeof(g))" begin
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

        s = one(T)
        d = nv(g)
        @test grid_dijkstra_dist(g, s, d) ≈ dijkstra_shortest_paths(g, s).dists[d]
        if GridGraphs.is_acyclic(g)
            @test grid_topological_sort_dist(g, s, d) ≈
                dijkstra_shortest_paths(g, s).dists[d]
        end
    end
end
