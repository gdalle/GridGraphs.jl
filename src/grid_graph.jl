"""
    GridGraph

Directed graph defined by a rectangular grid of vertices.

# Constructors

    GridGraph(vertex_weights; torus=false)

- `vertex_weights::AbstractMatrix`: vertex weight matrix used to define edge weights.
- `torus::Bool`: whether the grid wraps around at the borders.

    GridGraph(nrows, ncolumns; torus=false)

- `nrows` and `ncolumns`: size of the grid (assumes homogeneous vertex weights)
"""
struct GridGraph{R,W<:AbstractMatrix{R},torus} <: AbstractGraph{Int}
    vertex_weights::W
end

function GridGraph(vertex_weights::W; torus::Bool=false) where {W}
    return GridGraph{eltype(W),W,torus}(vertex_weights)
end

function GridGraph(nrows::Integer, ncols::Integer; torus::Bool=false)
    vertex_weights = Trues(nrows, ncols)
    return GridGraph(vertex_weights; torus)
end

## Attribute access

"""
    vertex_weights(g)

Retrieve the vertex weights matrix.
"""
vertex_weights(g::GridGraph) = g.vertex_weights

"""
    is_torus(g)

Check whether the grid is a torus.
"""
is_torus(::GridGraph{R,W,torus}) where {R,W,torus} = torus

## Size

"""
    height(g)

Compute the height of the grid (number of rows).
"""
height(g::GridGraph) = size(vertex_weights(g), 1)

"""
    width(g)

Compute the width of the grid (number of columns).
"""
width(g::GridGraph) = size(vertex_weights(g), 2)

## Weights

"""
    vertex_weight(g, v)

Retrieve the vertex weight associated with index `v`.
"""
vertex_weight(g::GridGraph, v::Integer) = vertex_weights(g)[v]

"""
    vertex_weight_coord(g, i, j)

Retrieve the vertex weight associated with coordinates `(i, j)`.
"""
vertex_weight_coord(g::GridGraph, i::Integer, j::Integer) = vertex_weights(g)[i, j]

## Indexing

"""
    coord_to_index(g, i, j)

Convert a grid coordinate tuple `(i,j)` into the index `v` of the associated vertex.
"""
function coord_to_index(g::GridGraph, i::Integer, j::Integer)
    h, w = height(g), width(g)
    if (1 <= i <= h) && (1 <= j <= w)
        v = (j - 1) * h + (i - 1) + 1  # enumerate column by column
        return v
    else
        return 0
    end
end

"""
    index_to_coord(g, v)

Convert a vertex index `v` into the tuple `(i,j)` of associated grid coordinates.
"""
function index_to_coord(g::GridGraph, v::Integer)
    if has_vertex(g, v)
        h = height(g)
        j = (v - 1) ÷ h + 1
        i = (v - 1) - h * (j - 1) + 1
        return (i, j)
    else
        return (0, 0)
    end
end
