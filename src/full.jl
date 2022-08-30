"""
    FullGridGraph

Concrete subtype of [`GridGraph`](@ref) for which all vertices are active.
"""
struct FullGridGraph{T,R,W,mt,md,mc} <:
       GridGraph{T,R,W,Trues{2,Tuple{OneTo{T},OneTo{T}}},mt,md,mc}
    weights::W
    active::Trues{2,Tuple{OneTo{T},OneTo{T}}}
end

function FullGridGraph{T,R,W,mt,md,mc}(weights::W) where {T,R,W,mt,md,mc}
    h, w = size(weights)
    active = Trues(T(h), T(w))
    return FullGridGraph{T,R,W,mt,md,mc}(weights, active)
end

function FullGridGraph(weights::W) where {R,W<:AbstractMatrix{R}}
    return FullGridGraph{Int,R,W,queen,cyclic,direct}(weights)
end

function FullAcyclicGridGraph(weights::W) where {R,W<:AbstractMatrix{R}}
    return FullGridGraph{Int,R,W,queen,acyclic,direct}(weights)
end

## Counting edges efficiently

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
