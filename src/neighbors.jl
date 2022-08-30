function Graphs.outneighbors(g::GridGraph, s::Integer)
    is, js = index_to_coord(g, s)
    return (coord_to_index(g, id, jd) for (id, jd) in outneighbors_coord(g, is, js))
end

function Graphs.inneighbors(g::GridGraph, d::Integer)
    id, jd = index_to_coord(g, d)
    return (coord_to_index(g, is, js) for (is, js) in inneighbors_coord(g, id, jd))
end

function Graphs.edges(g::GridGraph)
    return (Edge(s, d) for s in vertices(g) for d in outneighbors(g, s))
end

function Graphs.ne(g::GridGraph)
    counter = 0
    for u in vertices(g)
        for v in outneighbors(g, u)
            counter += 1
        end
    end
    return counter
end

"""
    outneighbors_coord(g, i, j)

Return the outneighbors of `(i, j)` listed in ascending index order.
"""
function outneighbors_coord end

function outneighbors_coord(
    g::GridGraph{T,R,W,A,queen,cyclic}, is::Integer, js::Integer
) where {T,R,W,A}
    candidates = (
        (is - 1, js - 1),  # top left
        (is + 0, js - 1),  # left
        (is + 1, js - 1),  # bottom left
        (is - 1, js + 0),  # top
        (is + 1, js + 0),  # bottom
        (is - 1, js + 1),  # top right
        (is + 0, js + 1),  # right
        (is + 1, js + 1),  # bottom right
    )
    return (
        (id, jd) for (id, jd) in candidates if has_vertex_coord(g, id, jd) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function outneighbors_coord(
    g::GridGraph{T,R,W,A,rook,cyclic}, is::Integer, js::Integer
) where {T,R,W,A}
    candidates = (
        (is + 0, js - 1),  # left
        (is - 1, js + 0),  # top
        (is + 1, js + 0),  # bottom
        (is + 0, js + 1),  # right
    )
    return (
        (id, jd) for (id, jd) in candidates if has_vertex_coord(g, id, jd) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function outneighbors_coord(
    g::GridGraph{T,R,W,A,queen,acyclic}, is::Integer, js::Integer
) where {T,R,W,A}
    candidates = (
        (is + 1, js + 0),  # bottom
        (is + 0, js + 1),  # right
        (is + 1, js + 1),  # bottom right
    )
    return (
        (id, jd) for (id, jd) in candidates if has_vertex_coord(g, id, jd) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function outneighbors_coord(
    g::GridGraph{T,R,W,A,rook,acyclic}, is::Integer, js::Integer
) where {T,R,W,A}
    candidates = (
        (is + 1, js + 0),  # bottom
        (is + 0, js + 1),  # right
    )
    return (
        (id, jd) for (id, jd) in candidates if has_vertex_coord(g, id, jd) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

"""
    inneighbors_coord(g, i, j)

Return the inneighbors of `(i, j)` listed in ascending index order.
"""
function inneighbors_coord end

function inneighbors_coord(
    g::GridGraph{T,R,W,A,mt,cyclic}, id::Integer, jd::Integer
) where {T,R,W,A,mt}
    return outneighbors_coord(g, id, jd)
end

function inneighbors_coord(
    g::GridGraph{T,R,W,A,queen,acyclic}, id::Integer, jd::Integer
) where {T,R,W,A}
    candidates = (
        (id - 1, jd - 1),  # top left
        (id + 0, jd - 1),  # left
        (id - 1, jd + 0),  # top
    )
    return (
        (is, js) for (is, js) in candidates if has_vertex_coord(g, is, js) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function inneighbors_coord(
    g::GridGraph{T,R,W,A,rook,acyclic}, id::Integer, jd::Integer
) where {T,R,W,A}
    candidates = (
        (id + 0, jd - 1),  # left
        (id - 1, jd + 0),  # top
    )
    return (
        (is, js) for (is, js) in candidates if has_vertex_coord(g, is, js) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end
