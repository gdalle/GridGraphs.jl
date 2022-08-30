function Graphs.has_edge(g::GridGraph, s::Integer, d::Integer)
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = index_to_coord(g, s)
        id, jd = index_to_coord(g, d)
        return has_edge_coord(g, is, js, id, jd)
    else
        return false
    end
end

## Auxiliary functions

function has_edge_coord(
    g::GridGraph{T,R,W,A,queen,cyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W,A}
    Δi, Δj = id - is, jd - js
    return (
        max(abs(Δi), abs(Δj)) == one(T) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function has_edge_coord(
    g::GridGraph{T,R,W,A,rook,cyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W,A}
    Δi, Δj = id - is, jd - js
    return (
        abs(Δi) + abs(Δj) == one(T) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function has_edge_coord(
    g::GridGraph{T,R,W,A,queen,acyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W,A}
    Δi, Δj = id - is, jd - js
    return (
        Δi >= zero(T) &&
        Δj >= zero(T) &&
        max(Δi, Δj) == one(T) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function has_edge_coord(
    g::GridGraph{T,R,W,A,rook,acyclic}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W,A}
    Δi, Δj = id - is, jd - js
    return (
        Δi >= zero(T) &&
        Δj >= zero(T) &&
        Δi + Δj == one(T) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end
