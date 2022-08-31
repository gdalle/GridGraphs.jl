using ForwardDiff
using GridGraphs
using GridGraphs: queen_acyclic_directions
using Random
using Test

Random.seed!(63)

weights_matrix = rand(10, 20)
∇1 = ForwardDiff.gradient(weights_matrix) do wm
    g = GridGraph(wm; directions=queen_acyclic_directions)
    grid_topological_sort(g, 1).dists[end]
end
∇2 = ForwardDiff.gradient(weights_matrix) do wm
    g = GridGraph(wm; directions=queen_acyclic_directions)
    grid_dijkstra(g, 1).dists[end]
end
∇3 = ForwardDiff.gradient(weights_matrix) do wm
    g = GridGraph(wm; directions=queen_acyclic_directions)
    grid_bellman_ford(g, 1).dists[end]
end

@test ∇1 == ∇2
@test ∇1 == ∇3
