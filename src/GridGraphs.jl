"""
    GridGraphs

A package for graphs defined by a rectangular grid of vertices.

GitHub repo: <https://github.com/gdalle/GridGraphs.jl>
"""
module GridGraphs

using DataStructures: BinaryHeap
using FillArrays: Trues
using Graphs: Graphs, AbstractGraph, Edge
using Graphs: nv, ne, vertices, edges, has_vertex, has_edge
using Graphs: inneighbors, outneighbors, src, dst
using SparseArrays: SparseMatrixCSC, sparse, _show_with_braille_patterns

include("directions.jl")
include("grid_graph.jl")
include("graphs_interface.jl")
include("shortest_paths.jl")

export GridDirection, get_tuple, get_direction
export ROOK_DIRECTIONS,
    ROOK_DIRECTIONS_PLUS_CENTER,
    ROOK_DIRECTIONS_ACYCLIC,
    QUEEN_DIRECTIONS,
    QUEEN_DIRECTIONS_PLUS_CENTER,
    QUEEN_DIRECTIONS_ACYCLIC
export GridGraph
export height,
    width,
    coord_to_index,
    index_to_coord,
    vertex_weight,
    vertex_active,
    has_direction,
    edge_weight
export grid_topological_sort,
    grid_dijkstra, grid_bellman_ford, get_path, path_to_matrix, ShortestPathTree

end
