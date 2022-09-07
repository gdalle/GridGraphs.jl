## Utilities

"""
    coord_to_index(g, i, j)

Convert a grid coordinate tuple `(i,j)` into the index `v` of the associated vertex.
"""
function coord_to_index(g::GridGraph{T}, i, j) where {T}
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
function index_to_coord(g::GridGraph{T}, v) where {T}
    if has_vertex(g, v)
        h = height(g)
        j = (v - 1) ÷ h + 1
        i = (v - 1) - h * (j - 1) + 1
        return (convert(T, i), convert(T, j))
    else
        return (zero(T), zero(T))
    end
end

## Vertices

Graphs.nv(g::GridGraph{T}) where {T} = height(g) * width(g)
Graphs.vertices(g::GridGraph{T}) where {T} = one(T):nv(g)

active_vertices(g::GridGraph) = (v for v in vertices(g) if active_vertex(g, v))

Graphs.has_vertex(g::GridGraph{T}, v) where {T} = one(T) <= v <= nv(g)

function has_vertex_coord(g::GridGraph{T}, i, j) where {T}
    return one(T) <= i <= height(g) && one(T) <= j <= width(g)
end

## Edges

function Graphs.has_edge(g::GridGraph, s, d)
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = index_to_coord(g, s)
        id, jd = index_to_coord(g, d)
        return has_edge_coord(g, is, js, id, jd)
    else
        return false
    end
end

function has_edge_coord(g::GridGraph, is, js, id, jd)
    Δi, Δj = id - is, jd - js
    return (
        has_direction_coord(g, Δi, Δj) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

## Neighbors

function Graphs.outneighbors(g::GridGraph, s)
    is, js = index_to_coord(g, s)
    return (coord_to_index(g, id, jd) for (id, jd) in outneighbors_coord(g, is, js))
end

function outneighbors_coord(g::GridGraph, is, js)
    # directions are listed in column major order
    candidates = ((is, js) + dir for dir in directions(g))
    return (
        (id, jd) for (id, jd) in candidates if has_vertex_coord(g, id, jd) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function Graphs.inneighbors(g::GridGraph, d)
    id, jd = index_to_coord(g, d)
    return (coord_to_index(g, is, js) for (is, js) in inneighbors_coord(g, id, jd))
end

function inneighbors_coord(g::GridGraph, id, jd)
    dirs = directions(g)
    # directions are listed in column major order
    candidates = ((id, jd) - dirs[k] for k in reverse(eachindex(directions(g))))
    return (
        (is, js) for (is, js) in candidates if has_vertex_coord(g, is, js) &&
        active_vertex_coord(g, is, js) &&
        active_vertex_coord(g, id, jd)
    )
end

function Graphs.edges(g::GridGraph)
    return (Edge(s, d) for s in active_vertices(g) for d in outneighbors(g, s))
end

## Edge count

function same_directions(directions1, directions2)
    if length(directions1) != length(directions2)
        return false
    else
        for (dir1, dir2) in zip(directions1, directions2)
            dir1 == dir2 || return false
        end
    end
    return true
end

isqueen(g::GridGraph) = same_directions(directions(g), QUEEN_DIRECTIONS)
isqueen_acyclic(g::GridGraph) = same_directions(directions(g), QUEEN_ACYCLIC_DIRECTIONS)
isrook(g::GridGraph) = same_directions(directions(g), ROOK_DIRECTIONS)
isrook_acyclic(g::GridGraph) = same_directions(directions(g), ROOK_ACYCLIC_DIRECTIONS)

function Graphs.ne(g::GridGraph)
    if all_active(g)
        if isqueen(g)
            return ne_queen(g)
        elseif isqueen(g)
            return ne_queen(g)
        elseif isrook(g)
            return ne_rook(g)
        elseif isrook_acyclic(g)
            return ne_rook_acyclic(g)
        else
            return ne_generic(g)
        end
    else
        return ne_generic(g)
    end
end

function ne_generic(g::GridGraph)
    counter = 0
    for u in vertices(g)
        for v in outneighbors(g, u)
            counter += 1
        end
    end
    return counter
end

function ne_queen(g::GridGraph)
    h, w = height(g), width(g)
    @assert h >= 2 && w >= 2
    return (
        (h - 2) * (w - 2) * 8 +  # center
        2 * (h - 2) * 5 +  # vertical borders
        2 * (w - 2) * 5 +  # horizontal borders
        4 * 3  # corners
    )
end

function ne_queen_acyclic(g::GridGraph)
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

function ne_rook(g::GridGraph)
    h, w = height(g), width(g)
    @assert h >= 2 && w >= 2
    return (
        (h - 2) * (w - 2) * 4 +  # center
        2 * (h - 2) * 3 +  # vertical borders
        2 * (w - 2) * 3 +  # horizontal borders
        4 * 2  # corners
    )
end

function ne_rook_acyclic(g::GridGraph)
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
