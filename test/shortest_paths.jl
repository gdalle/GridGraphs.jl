using ForwardDiff
using GridGraphs
using GridGraphs.GridShortestPaths
using Random
using Test

Random.seed!(63)

## Correctness

g = GridGraph(rand(3, 4); directions=QUEEN_DIRECTIONS_ACYCLIC)
s, d = 1, nv(g)
spt_ref = Graphs.dijkstra_shortest_paths(g, s)

spt1 = @inferred grid_dijkstra(g, s)
@test spt1.dists[d] ≈ spt_ref.dists[d]
@test 1 <= length(get_path(spt1, s, d)) <= d

spt2 = @inferred grid_bellman_ford(g, s)
@test spt2.dists[d] ≈ spt_ref.dists[d]
@test 1 <= length(get_path(spt2, s, d)) <= d

spt3 = @inferred grid_topological_sort(g, s)
@test spt3.dists[d] ≈ spt_ref.dists[d]
@test 1 <= length(get_path(spt3, s, d)) <= d

## Autodiff

vertex_weights = rand(10, 20)
∇1 = ForwardDiff.gradient(vertex_weights) do x
    g = GridGraph(x; directions=QUEEN_DIRECTIONS_ACYCLIC)
    grid_topological_sort(g, 1).dists[end]
end
∇2 = ForwardDiff.gradient(vertex_weights) do x
    g = GridGraph(x; directions=QUEEN_DIRECTIONS_ACYCLIC)
    grid_dijkstra(g, 1).dists[end]
end
∇3 = ForwardDiff.gradient(vertex_weights) do x
    g = GridGraph(x; directions=QUEEN_DIRECTIONS_ACYCLIC)
    grid_bellman_ford(g, 1).dists[end]
end

@test ∇1 == ∇2
@test ∇1 == ∇3
