"""
    GridGraph{
        T<:Integer,
        R<:Real,
        W<:AbstractMatrix{R},
        A<:AbstractMatrix{Bool}
    }

Graph defined by a grid of vertices with index type `T`.

# Fields

- `weights::W`: vertex weights matrix, which serve to define edge weights.
- `active::A`: vertex activity matrix. All the vertices on the grid exist, but only active vertices can have edges (inactive vertices are isolated).
- `directions::Vector{GridDirection}`: the set of legal directions which are used to define edges.
- `diag_through_corner::Bool`: defines how the weight of a diagonal edge is computed.

# See also

- [`edge_weight(g, s, d)`](@ref)
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

"""
    GridGraph{T}(weights[; active, directions, diag_through_corner])

User-friendly constructor.
By default, all vertices are active, all directions are allowed, and edge weights are always computed based on the arrival vertex alone.
"""
function GridGraph{T}(
    weights;
    active=Trues(size(weights)),
    directions=QUEEN_DIRECTIONS_PLUS_CENTER,
    diag_through_corner=false,
) where {T}
    return GridGraph{T}(weights, active, directions, diag_through_corner)
end

function GridGraph(
    weights;
    active=Trues(size(weights)),
    directions=QUEEN_DIRECTIONS,
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

"""
    active_vertex(g, v)

Check if vertex `v` is active.
"""
active_vertex(g::GridGraph, v) = g.active[v]
active_vertex_coord(g::GridGraph, i, j) = g.active[i, j]
all_active(g::GridGraph) = all(isone, g.active)
nb_active(g::GridGraph) = sum(g.active)
fraction_active(g::GridGraph) = sum(g.active) / length(g.active)

"""
    has_direction(g, dir)

Check if direction `dir` is a valid edge direction.
"""
has_direction(g::GridGraph, dir::GridDirection) = insorted(dir, g.directions)
has_direction_coord(g::GridGraph, Δi, Δj) = has_direction(g, get_direction(Δi, Δj))
directions(g::GridGraph) = g.directions
is_acyclic(g::GridGraph) = is_acyclic(directions(g))

"""
    diag_through_corner(g)

Check if diagonal edge weights are computed using the corner vertices.
"""
diag_through_corner(g::GridGraph) = g.diag_through_corner

"""
    has_negative_weights(g)

Check if any of the vertex weights are negative.

By default this check is not included in Dijkstra's algorithm to save time.
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

"""
    Base.show(io, g)

Display a GridGraph using braille patterns when not all vertices are active.
"""
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
