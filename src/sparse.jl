"""
    FullGridGraph

Concrete subtype of [`GridGraph`](@ref) for which only some vertices are active.
"""
struct SparseGridGraph{T,R,W,A,mt,md,mc} <: GridGraph{T,R,W,A,mt,md,mc}
    weights::W
    active::A
end

function SparseGridGraph(weights::W, active::A) where {R,W<:AbstractMatrix{R},A}
    return FullGridGraph{Int,R,W,A,queen,cyclic,direct}(weights)
end
