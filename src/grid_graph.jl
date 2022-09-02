"""
    GridGraph{T<:Integer,R<:Real,W<:AbstractMatrix{R},A<:AbstractMatrix{Bool}}

Graphs defined by a grid of vertices with index type `T`.

# Fields

- `weights::W`: vertex weights matrix. The weight of an edge is a simple function of a few vertex weights, depending on the type of grid.
- `active::A`: vertex activity matrix. All the vertices on the grid exist, but only some are active (i.e. can have edges with their neighbors).
"""
struct GridGraph{T<:Integer,R<:Real,W<:AbstractMatrix{R},A<:AbstractMatrix{Bool}} <:
       AbstractGraph{T}
    weights::W
    active::A
    directions::Vector{GridDirection}
    diag_through_corner::Bool

    function GridGraph{T}(
        weights::W, active::A, directions, diag_through_corner
    ) where {T,R,W<:AbstractMatrix{R},A<:AbstractMatrix{Bool}}
        return new{T,R,W,A}(
            weights, active, sort(unique(directions)), Bool(diag_through_corner)
        )
    end
end

function GridGraph{T}(
    weights;
    active=Trues(size(weights)),
    directions=queen_directions,
    diag_through_corner=false,
) where {T}
    return GridGraph{T}(weights, active, directions, diag_through_corner)
end

function GridGraph(
    weights;
    active=Trues(size(weights)),
    directions=queen_directions,
    diag_through_corner=false,
)
    return GridGraph{Int}(weights, active, directions, diag_through_corner)
end

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

active_vertex(g::GridGraph, v) = g.active[v]
active_vertex_coord(g::GridGraph, i, j) = g.active[i, j]
all_active(g::GridGraph) = all(isone, g.active)

directions(g::GridGraph) = g.directions
has_direction(g::GridGraph, dir::GridDirection) = insorted(dir, g.directions)
has_direction_coord(g::GridGraph, Δi, Δj) = has_direction(g, get_direction(Δi, Δj))
is_acyclic(g::GridGraph) = is_acyclic(directions(g))

diag_through_corner(g::GridGraph) = g.diag_through_corner

"""
    has_negative_weights(g)

Check whether there are any negative weights.
"""
function has_negative_weights(g::GridGraph{T,R}) where {T,R}
    return any(<(zero(R)), g.weights)
end

"""
    vertex_weight(g, v)

Retrieve the vertex weight associated with index `v`.
"""
vertex_weight(g::GridGraph, v) = g.weights[v]
vertex_weight_coord(g::GridGraph, i, j) = g.weights[i, j]

## Pretty printing

function Base.show(io::IO, g::GridGraph{T,R,W,A}) where {T,R,W,A}
    print(
        io,
        "GridGraph with $T vertices and $R weights.\nWeights matrix: $W\nActive matrix: $A\nDirections: $(g.directions)\nDiagonal through corner: $(g.diag_through_corner)\n",
    )
    if sum(g.active) < length(g.active)
        _show_with_braille_patterns(io, SparseMatrixCSC(g.active))
    end
    return nothing
end
