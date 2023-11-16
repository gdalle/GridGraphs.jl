using Graphs
using GridGraphs
using GridGraphs: SETS_OF_DIRECTIONS
using GridGraphs:
    index_to_coord,
    coord_to_index,
    height,
    width,
    directions,
    is_acyclic,
    nb_corners_for_diag,
    pythagoras_cost_for_diag,
    slow_weights
using Random
using Test

Random.seed!(63)

#=
Test grid

....
..@.
.@..

=#

vertex_weights = ones(3, 4);
vertex_activities = ones(Bool, 3, 4);
vertex_activities[2, 3] = false;
vertex_activities[3, 2] = false;

graphs_to_test = GridGraph[]

for directions in (
    ROOK_DIRECTIONS,
    ROOK_DIRECTIONS_PLUS_CENTER,
    ROOK_DIRECTIONS_ACYCLIC,
    QUEEN_DIRECTIONS,
    QUEEN_DIRECTIONS_PLUS_CENTER,
    QUEEN_DIRECTIONS_ACYCLIC,
)
    for nb_corners_for_diag in (0, 1, 2)
        for pythagoras_cost_for_diag in (true, false)
            try
                g = GridGraph(
                    vertex_weights;
                    vertex_activities,
                    directions,
                    nb_corners_for_diag,
                    pythagoras_cost_for_diag,
                )
                push!(graphs_to_test, g)
            catch e
                nothing
            end
        end
    end
end

for g in graphs_to_test
    test_name = string(typeof(g))
    @testset "$test_name" begin
        @info "Testing" g
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
        @test index_to_coord(g, height(g) + 1, width(g) + 1) == 0

        ## Vertices

        @test all(has_vertex(g, v) for v in vertices(g))
        @test !has_vertex(g, nv(g) + 1)

        ## Edges

        @test ne(g) == length(collect(edges(g)))
        @test all(has_edge(g, src(ed), dst(ed)) for ed in edges(g))
        @test !has_edge(g, nv(g), 1)
        @test !has_edge(g, 1, nv(g) + 1)

        g2 = deepcopy(g)
        g2.vertex_activities .= true
        @test ne(g2) == length(collect(edges(g2)))

        ## Diagonals

        if directions(g) in
            (ROOK_DIRECTIONS, ROOK_DIRECTIONS_PLUS_CENTER, ROOK_DIRECTIONS_ACYCLIC)
            @test !has_edge(g, coord_to_index(g, 1, 1), coord_to_index(g, 2, 2))
        elseif directions(g) in
            (QUEEN_DIRECTIONS, QUEEN_DIRECTIONS_PLUS_CENTER, QUEEN_DIRECTIONS_ACYCLIC)
            @test has_edge(g, coord_to_index(g, 1, 1), coord_to_index(g, 2, 2))
        end

        ## Hole

        if directions(g) in
            (QUEEN_DIRECTIONS, QUEEN_DIRECTIONS_PLUS_CENTER, QUEEN_DIRECTIONS_ACYCLIC)
            if nb_corners_for_diag(g) == 0
                @test has_edge(g, coord_to_index(g, 2, 2), coord_to_index(g, 3, 3)) # 0 corner
                @test has_edge(g, coord_to_index(g, 1, 3), coord_to_index(g, 2, 4)) # 1 corner
            elseif nb_corners_for_diag(g) == 1
                @test !has_edge(g, coord_to_index(g, 2, 2), coord_to_index(g, 3, 3)) # 0 corner
                @test has_edge(g, coord_to_index(g, 1, 3), coord_to_index(g, 2, 4)) # 1 corner
            elseif nb_corners_for_diag(g) == 2
                @test !has_edge(g, coord_to_index(g, 2, 2), coord_to_index(g, 3, 3)) # 0 corner
                @test !has_edge(g, coord_to_index(g, 1, 3), coord_to_index(g, 2, 4)) # 1 corner
            end
        end

        ## Weights

        @test slow_weights(g) == weights(g)

        if directions(g) in
            (QUEEN_DIRECTIONS, QUEEN_DIRECTIONS_PLUS_CENTER, QUEEN_DIRECTIONS_ACYCLIC)
            if pythagoras_cost_for_diag(g)
                @test sort(unique(weights(g))) ≈ [0.0, 1.0, sqrt(2)]
            else
                @test sort(unique(weights(g))) ≈ [0.0, 1.0]
            end
        end
    end
end
