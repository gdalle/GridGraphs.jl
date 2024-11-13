using Graphs
using GridGraphs
using GridGraphs: index_to_coord, coord_to_index, height, width
using Test

vertex_weights = float.(reshape(1:12, 3, 4));

graphs_to_test = [GridGraph(vertex_weights; torus) for torus in (true, false)]

g = graphs_to_test[1]

@testset "$(typeof(g))" for g in graphs_to_test
    @test eltype(g) == Int
    @test edgetype(g) == Edge{Int}
    @test is_directed(g)
    @test is_directed(typeof(g))

    @test height(g) == 3
    @test width(g) == 4

    @test nv(g) == 12
    @test length(vertices(g)) == nv(g)

    ## Indexing 

    @test [coord_to_index(g, i, j) for j in 1:width(g) for i in 1:height(g)] == 1:nv(g)
    @test [index_to_coord(g, v) for v in vertices(g)] == [(i, j) for j in 1:width(g) for i in 1:height(g)]
    @test index_to_coord(g, nv(g) + 1) == (0, 0)
    @test coord_to_index(g, height(g) + 1, width(g) + 1) == 0

    ## Vertices

    @test all(has_vertex(g, v) for v in vertices(g))
    @test !has_vertex(g, 0)
    @test !has_vertex(g, nv(g) + 1)

    ## Edges

    @test ne(g) == length(collect(edges(g)))
    @test all(has_edge(g, src(ed), dst(ed)) for ed in edges(g))
    @test !has_edge(g, nv(g), 1)
    @test !has_edge(g, 1, nv(g) + 1)

    ## Diagonals

    @test !has_edge(g, coord_to_index(g, 1, 1), coord_to_index(g, 2, 2))
end
