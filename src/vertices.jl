Graphs.nv(g::GridGraph{T}) where {T} = height(g) * width(g)
Graphs.vertices(g::GridGraph{T}) where {T} = one(T):nv(g)

Graphs.has_vertex(g::GridGraph{T}, v::Integer) where {T} = one(T) <= v <= nv(g)

function has_vertex_coord(g::GridGraph{T}, i::Integer, j::Integer) where {T}
    return one(T) <= i <= height(g) && one(T) <= j <= width(g)
end

active_vertex(g::GridGraph, v::Integer) = g.active[v]
active_vertex_coord(g::GridGraph, i::Integer, j::Integer) = g.active[i, j]

"""
    coord_to_index(g, i, j)

Convert a grid coordinate tuple `(i,j)` into the index `v` of the associated vertex.
"""
function coord_to_index(g::GridGraph{T}, i::Integer, j::Integer) where {T}
    h, w = height(g), width(g)
    if (1 <= i <= h) && (1 <= j <= w)
        v = (j - 1) * h + (i - 1) + 1  # enumerate column by column
        return convert(T, v)
    else
        return zero(T)
    end
end

"""
    index_to_coord(g, v)

Convert a vertex index `v` into the tuple `(i,j)` of associated grid coordinates.
"""
function index_to_coord(g::GridGraph{T}, v::Integer) where {T}
    if has_vertex(g, v)
        h = height(g)
        j = (v - 1) ÷ h + 1
        i = (v - 1) - h * (j - 1) + 1
        return convert(T, i), convert(T, j)
    else
        return (zero(T), zero(T))
    end
end
