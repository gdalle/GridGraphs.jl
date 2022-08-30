"""
    FullGridGraph
"""
struct FullGridGraph{T<:Integer,R<:Real,W<:AbstractMatrix{R},mt,md,mc} <:
       AbstractGridGraph{T,R,mt,md,mc}
    weights::W
end

## Default constructors

function FullGridGraph(weights::W) where {R,W<:AbstractMatrix{R}}
    return FullGridGraph{Int,R,W,queen,cyclic,destination}(weights)
end

function FullGridGraph(weights_vec::AbstractVector, h::Integer, w::Integer)
    weights = reshape(weights_vec, h, w)
    return FullGridGraph(weights)
end

function FullAcyclicGridGraph(weights::W) where {R,W<:AbstractMatrix{R}}
    return FullGridGraph{Int,R,W,queen,acyclic,destination}(weights)
end

## Interface

height(g::FullGridGraph{T}) where {T} = convert(T, size(g.weights, 1))
width(g::FullGridGraph{T}) where {T} = convert(T, size(g.weights, 2))

vertex_weight_coord(g::FullGridGraph, i::Integer, j::Integer) = g.weights[i, j]

function has_negative_weights(g::FullGridGraph{T,R}) where {T,R}
    return any(<(zero(R)), g.weights)
end

## Checking edges

function has_edge_coord(
    ::FullGridGraph{T,R,W,queen,cyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W}
    Δi, Δj = id - is, jd - js
    return max(abs(Δi), abs(Δj)) == one(T)
end

function has_edge_coord(
    ::FullGridGraph{T,R,W,rook,cyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W}
    Δi, Δj = id - is, jd - js
    return abs(Δi) + abs(Δj) == one(T)
end

function has_edge_coord(
    ::FullGridGraph{T,R,W,queen,acyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W}
    Δi, Δj = id - is, jd - js
    return Δi >= zero(T) && Δj >= zero(T) && max(Δi, Δj) == one(T)
end

function has_edge_coord(
    ::FullGridGraph{T,R,W,rook,acyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W}
    Δi, Δj = id - is, jd - js
    return Δi >= zero(T) && Δj >= zero(T) && Δi + Δj == one(T)
end

function Graphs.has_edge(g::FullGridGraph, s::Integer, d::Integer)
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = node_coord(g, s)
        id, jd = node_coord(g, d)
        return has_edge_coord(g, is, js, id, jd)
    else
        return false
    end
end

## Counting edges

function Graphs.ne(g::FullGridGraph{T,R,W,queen,cyclic}) where {T,R,W}
    h, w = height(g), width(g)
    @assert h >= 2 && w >= 2
    return (
        (h - 2) * (w - 2) * 8 +  # center
        2 * (h - 2) * 5 +  # vertical borders
        2 * (w - 2) * 5 +  # horizontal borders
        4 * 3  # corners
    )
end

function Graphs.ne(g::FullGridGraph{T,R,W,rook,cyclic}) where {T,R,W}
    h, w = height(g), width(g)
    @assert h >= 2 && w >= 2
    return (
        (h - 2) * (w - 2) * 4 +  # center
        2 * (h - 2) * 3 +  # vertical borders
        2 * (w - 2) * 3 +  # horizontal borders
        4 * 2  # corners
    )
end

function Graphs.ne(g::FullGridGraph{T,R,W,queen,acyclic}) where {T,R,W}
    h, w = height(g), width(g)
    @assert h >= 2 && w >= 2
    return (
        (h - 2) * (w - 2) * 3 +  # center
        (h - 2) * 3 +  # left border
        (h - 2) * 1 +  # right border
        (w - 2) * 3 +  # top border
        (w - 2) * 1 +  # bottom border
        3 +  # top left corner
        1 +  # top right corner
        1 +  # bottom left corner
        0  # bottom right corner
    )
end

function Graphs.ne(g::FullGridGraph{T,R,W,rook,acyclic}) where {T,R,W}
    h, w = height(g), width(g)
    @assert h >= 2 && w >= 2
    return (
        (h - 2) * (w - 2) * 2 +  # center
        (h - 2) * 2 +  # left border
        (h - 2) * 1 +  # right border
        (w - 2) * 2 +  # top border
        (w - 2) * 1 +  # bottom border
        2 +  # top left corner
        1 +  # top right corner
        1 +  # bottom left corner
        0  # bottom right corner
    )
end

## Listing neighbors

function Graphs.outneighbors(g::FullGridGraph{T}, s::Integer) where {T}
    h, w = height(g), width(g)
    is, js = node_coord(g, s)
    return (
        node_index(g, id, jd) for
        (id, jd) in grid_neighbors(is, js; h=h, w=w) if has_edge_coord(g, is, js, id, jd)
    )
end

function Graphs.inneighbors(g::FullGridGraph{T}, d::Integer) where {T}
    h, w = height(g), width(g)
    id, jd = node_coord(g, d)
    return (
        node_index(g, is, js) for
        (is, js) in grid_neighbors(id, jd; h=h, w=w) if has_edge_coord(g, is, js, id, jd)
    )
end
