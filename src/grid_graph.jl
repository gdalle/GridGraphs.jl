"""
    GridGraph{T<:Integer,R<:Real,W<:AbstractMatrix{R},A<:AbstractMatrix{Bool},mt,md,mc}

Abstract supertype for graphs defined by a grid of vertices.

# Required fields

- `weights::W`: vertex weights matrix. The weight of an edge is a simple function of a few vertex weights, depending on the type of grid.
- `active::A`: vertex activity matrix. All the vertices on the grid exist, but only some are active (i.e. can have edges with their neighbors).

# Type parameters

- `T`: type of vertex indices
- `R`: type of edge weights
- `W`: type of vertex weights matrix
- `A`: type of vertex activity matrix
- `mt::MoveType`
- `md::MoveDirection`
- `mc::MoveCost`
"""
abstract type GridGraph{
    T<:Integer,R<:Real,W<:AbstractMatrix{R},A<:AbstractMatrix{Bool},mt,md,mc
} <: AbstractGraph{T} end

## Basic functions

"""
    height(g)

Compute the height of the grid (number of rows).
"""
height(g::GridGraph{T}) where {T} = convert(T, size(g.weights, 1))

"""
    width(g)

Compute the width of the grid (number of columns).
"""
width(g::GridGraph{T}) where {T} = convert(T, size(g.weights, 2))

Base.eltype(::GridGraph{T}) where {T} = T
Graphs.edgetype(::GridGraph{T}) where {T} = Edge{T}

Graphs.is_directed(::GridGraph) = true
Graphs.is_directed(::Type{<:GridGraph}) = true
