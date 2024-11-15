"""
    GridGraphs

A package for graphs defined by a rectangular grid of vertices.
"""
module GridGraphs

using FillArrays: Trues
using Graphs: Graphs, AbstractGraph, Edge
using Graphs: nv, ne, vertices, edges, has_vertex, has_edge
using Graphs: inneighbors, outneighbors, src, dst
using SparseArrays: SparseMatrixCSC, sparse

include("directions.jl")
include("grid_graph.jl")
include("graphs_interface.jl")

export GridGraph
export height,
    width,
    coord_to_index,
    index_to_coord,
    vertex_weight,
    edge_weight,
    vertex_weights,
    is_torus

end
