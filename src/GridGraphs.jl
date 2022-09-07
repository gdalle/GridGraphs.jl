"""
    GridGraphs

A package for graphs defined by a grid of vertices.
"""
module GridGraphs

using Base: OneTo
using DataStructures: BinaryHeap
using FillArrays: Trues
using Graphs: Graphs, AbstractGraph, Edge
using Graphs: nv, ne, vertices, edges, has_vertex, has_edge
using Graphs: inneighbors, outneighbors, src, dst
using SparseArrays: SparseMatrixCSC, sparse, _show_with_braille_patterns

include("directions.jl")
include("grid_graph.jl")
include("vertices_edges.jl")
include("weights.jl")
include("shortest_paths.jl")

export GridDirection
export GridGraph
export grid_topological_sort
export grid_dijkstra
export grid_bellman_ford
export get_path
export path_to_matrix

end
