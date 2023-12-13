"""
    GridGraphs

A package for graphs defined by a rectangular grid of vertices.

GitHub repo: <https://github.com/gdalle/GridGraphs.jl>
"""
module GridGraphs

using DocStringExtensions
using FillArrays: Trues
using Graphs: Graphs, AbstractGraph, Edge
using Graphs: nv, ne, vertices, edges, has_vertex, has_edge
using Graphs: neighbors, inneighbors, outneighbors, src, dst
using LinearAlgebra: Symmetric
using SparseArrays: SparseMatrixCSC, sparse, _show_with_braille_patterns

include("directions.jl")
include("grid_graph.jl")
include("graphs_interface.jl")

export ROOK_DIRECTIONS, ROOK_DIRECTIONS_PLUS_CENTER
export QUEEN_DIRECTIONS, QUEEN_DIRECTIONS_PLUS_CENTER
export GridGraph
export height, width, coord_to_index
index_to_coord

end
