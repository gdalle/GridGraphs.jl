using Graphs
using GridGraphs
using GridGraphs: directions, diag_corners, straight_cost, diag_cost
using Test

#=
Test grid

....
..@.
.@..

=#

activities = ones(Bool, 3, 4);
activities[2, 3] = false;
activities[3, 2] = false;

graphs_to_test = GridGraph[]

for directions in (
    ROOK_DIRECTIONS,
    ROOK_DIRECTIONS_PLUS_CENTER,
    QUEEN_DIRECTIONS,
    QUEEN_DIRECTIONS_PLUS_CENTER,
)
    for diag_corners in (0, 1, 2)
        g = GridGraph(size(activities)...; activities, directions, diag_corners)
        push!(graphs_to_test, g)
    end
end

for g in graphs_to_test
    test_name = string(typeof(g))
    @testset "$test_name" begin
        @test eltype(g) == Int
        @test edgetype(g) == Edge{Int}
        @test !is_directed(g)
        @test !is_directed(typeof(g))

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
        @test !has_vertex(g, nv(g) + 1)

        ## Edges

        @test ne(g) == length(collect(edges(g)))
        @test all(has_edge(g, src(ed), dst(ed)) for ed in edges(g))
        @test !has_edge(g, nv(g), 1)
        @test !has_edge(g, 1, nv(g) + 1)

        g2 = deepcopy(g)
        g2.activities .= true
        @test ne(g2) == length(collect(edges(g2)))

        ## Diagonals

        if directions(g) in (ROOK_DIRECTIONS, ROOK_DIRECTIONS_PLUS_CENTER)
            @test !has_edge(g, coord_to_index(g, 1, 1), coord_to_index(g, 2, 2))
        elseif directions(g) in (QUEEN_DIRECTIONS, QUEEN_DIRECTIONS_PLUS_CENTER)
            @test has_edge(g, coord_to_index(g, 1, 1), coord_to_index(g, 2, 2))
        end

        ## Hole

        if directions(g) in (QUEEN_DIRECTIONS, QUEEN_DIRECTIONS_PLUS_CENTER)
            if diag_corners(g) == 0
                @test has_edge(g, coord_to_index(g, 2, 2), coord_to_index(g, 3, 3)) # 0 corner
                @test has_edge(g, coord_to_index(g, 1, 3), coord_to_index(g, 2, 4)) # 1 corner
            elseif diag_corners(g) == 1
                @test !has_edge(g, coord_to_index(g, 2, 2), coord_to_index(g, 3, 3)) # 0 corner
                @test has_edge(g, coord_to_index(g, 1, 3), coord_to_index(g, 2, 4)) # 1 corner
            elseif diag_corners(g) == 2
                @test !has_edge(g, coord_to_index(g, 2, 2), coord_to_index(g, 3, 3)) # 0 corner
                @test !has_edge(g, coord_to_index(g, 1, 3), coord_to_index(g, 2, 4)) # 1 corner
            end
        end

        ## Weights

        @test sort(unique(weights(g))) == unique([0, straight_cost(g), diag_cost(g)])
    end
end
