## Type parameters

@enum MoveType rook queen
@enum MoveDirection cyclic acyclic
@enum MoveCost destination diagonal

## Abstract type

"""
    AbstractGridGraph{T<:Integer,R<:Real,mt,md,mc}

Abstract supertype for grid graphs with vertices of type `T` and weights of type `R`.

To implement a concrete subtype `G <: AbstractGridGraph`, the following methods need to be defined (see [the Graphs.jl docs](https://juliagraphs.org/Graphs.jl/dev/ecosystem/interface/)):

- `GridGraphs.height(g::G)`
- `GridGraphs.width(g::G)`
- `GridGraphs.vertex_weight_coord(g::G, i, j)`
- `GridGraphs.has_negative_weights(g::G)`
- `Graphs.ne(g::G)`
- `Graphs.has_edge(g::G, s, d)`
- `Graphs.outneighbors(g::G, s)`
- `Graphs.inneighbors(g::G, d)`
"""
abstract type AbstractGridGraph{T<:Integer,R<:Real,mt,md,mc} <: AbstractGraph{T} end

## Interface to implement

"""
    height(g)

Compute the height of the grid (number of rows).
"""
height(::G) where {G<:AbstractGridGraph} = error("Not implemented for type $G")

"""
    width(g)

Compute the width of the grid (number of columns).
"""
width(::G) where {G<:AbstractGridGraph} = error("Not implemented for type $G")

"""
    vertex_weight_coord(g, i, j)

Retrieve the vertex weight associated with coordinates `(i, j)`.
"""
function vertex_weight_coord(::G, ::Integer, ::Integer) where {G<:AbstractGridGraph}
    return error("Not implemented for type $G")
end

"""
    has_negative_weights(g)

Check whether there are any negative weights.
"""
function has_negative_weights(::G) where {G<:AbstractGridGraph}
    return error("Not implemented for type $G")
end

function Graphs.ne(::G) where {G<:AbstractGridGraph}
    return error("Not implemented for type $G")
end

function Graphs.has_edge(::G, ::Integer, ::Integer) where {G<:AbstractGridGraph}
    return error("Not implemented for type $G")
end

function Graphs.outneighbors(::G, ::Integer) where {G<:AbstractGridGraph}
    return error("Not implemented for type $G")
end

function Graphs.inneighbors(::G, ::Integer) where {G<:AbstractGridGraph}
    return error("Not implemented for type $G")
end

## Other fallbacks

Base.eltype(::AbstractGridGraph{T}) where {T} = T
Graphs.edgetype(::AbstractGridGraph{T}) where {T} = Edge{T}

Graphs.is_directed(::AbstractGridGraph) = true
Graphs.is_directed(::Type{<:AbstractGridGraph}) = true

Graphs.nv(g::AbstractGridGraph{T}) where {T} = height(g) * width(g)
Graphs.vertices(g::AbstractGridGraph{T}) where {T} = one(T):nv(g)
Graphs.has_vertex(g::AbstractGridGraph{T}, v::Integer) where {T} = one(T) <= v <= nv(g)

function Graphs.edges(g::AbstractGridGraph)
    return (Edge(s, d) for s in vertices(g) for d in outneighbors(g, s))
end

## Grid features

function move_type(::AbstractGridGraph{T,R,mt,md,mc})::MoveType where {T,R,mt,md,mc}
    return mt
end

function move_direction(
    ::AbstractGridGraph{T,R,mt,md,mc}
)::MoveDirection where {T,R,mt,md,mc}
    return md
end

function move_cost(::AbstractGridGraph{T,R,mt,md,mc})::MoveCost where {T,R,mt,md,mc}
    return mc
end

## Indexing translators

"""
    node_index(g, i, j)

Convert a grid coordinate tuple `(i,j)` into the index `v` of the associated vertex.
"""
function node_index(g::AbstractGridGraph{T}, i::Integer, j::Integer) where {T}
    h, w = height(g), width(g)
    𝟘, 𝟙 = zero(T), one(T)
    if (𝟙 <= i <= h) && (𝟙 <= j <= w)
        v = (j - 𝟙) * h + (i - 𝟙) + 𝟙  # enumerate column by column
        return convert(T, v)
    else
        return 𝟘
    end
end

"""
    node_coord(g, v)

Convert a vertex index `v` into the associate tuple `(i,j)` of grid coordinates.
"""
function node_coord(g::AbstractGridGraph{T}, v::Integer) where {T}
    𝟘, 𝟙 = zero(T), one(T)
    if has_vertex(g, v)
        h = height(g)
        j = (v - 𝟙) ÷ h + 𝟙
        i = (v - 𝟙) - h * (j - 𝟙) + 𝟙
        return convert(T, i), convert(T, j)
    else
        return (𝟘, 𝟘)
    end
end

## Neighbors

"""
    grid_neighbors(g, i, j)

Return an iterator of grid neighbors listed in ascending index order.
"""
function grid_neighbors(i::T, j::T; h::Integer, w::Integer) where {T<:Integer}
    𝟙 = one(T)
    candidates = (
        (i - 𝟙, j - 𝟙),  # top left
        (i, j - 𝟙),  # left
        (i + 𝟙, j - 𝟙),  # bottom left
        (i - 𝟙, j),  # top
        (i + 𝟙, j),  # bottom
        (i - 𝟙, j + 𝟙),  # top right
        (i, j + 𝟙),  # right
        (i + 𝟙, j + 𝟙),  # bottom right
    )
    selected = ((id, jd) for (id, jd) in candidates if (𝟙 <= id <= h) && (𝟙 <= jd <= w))
    return selected
end

## Weights

"""
    vertex_weight(g, v)

Retrieve the vertex weight associated with index `v`.
"""
function vertex_weight(g::AbstractGridGraph, v::Integer)
    i, j = node_coord(g, v)
    return vertex_weight_coord(g, i, j)
end

function edge_weight(
    g::AbstractGridGraph{T,R,mt,md,destination}, s::Integer, d::Integer
) where {T,R,mt,md}
    return vertex_weight(g, d)
end

function edge_weight(
    g::AbstractGridGraph{T,R,mt,md,diagonal}, s::Integer, d::Integer
) where {T,R,mt,md}
    is, js = node_coord(g, s)
    id, jd = node_coord(g, d)
    return edge_weight_coord(g, is, js, id, jd)
end

function edge_weight_coord(
    g::AbstractGridGraph{T,R,mt,md,diagonal},
    is::Integer,
    js::Integer,
    id::Integer,
    jd::Integer,
) where {T,R,mt,md}
    dest_weight = vertex_weight_coord(g, id, jd)
    if is == id || js == jd
        return dest_weight
    else
        ic1, jc1 = id, js
        ic2, jc2 = is, jd
        corner1_weight = vertex_weight_coord(g, ic1, jc1)
        corner2_weight = vertex_weight_coord(g, ic2, jc2)
        return min(
            sqrt(corner1_weight^2 + dest_weight^2), sqrt(corner2_weight^2 + dest_weight^2)
        )
    end
end

"""
    Graphs.weights(g)

Compute a sparse matrix of edge weights based on the vertex weights.
"""
function Graphs.weights(g::AbstractGridGraph{T,R}) where {T,R}
    E = ne(g)
    I = Vector{T}(undef, E)
    J = Vector{T}(undef, E)
    V = Vector{R}(undef, E)
    for (k, ed) in enumerate(edges(g))
        s, d = src(ed), dst(ed)
        I[k] = s
        J[k] = d
        V[k] = edge_weight(g, s, d)
    end
    return sparse(I, J, V, nv(g), nv(g))
end

## Misc

Graphs.reverse(g::AbstractGridGraph) = error("Not implemented")
