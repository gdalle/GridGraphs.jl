Base.eltype(::GridGraph) = Int
Graphs.edgetype(::GridGraph) = Edge{Int}

Graphs.is_directed(::GridGraph) = true
Graphs.is_directed(::Type{<:GridGraph}) = true

Graphs.nv(g::GridGraph) = height(g) * width(g)
Graphs.vertices(g::GridGraph) = 1:nv(g)

Graphs.has_vertex(g::GridGraph, v) = 1 <= v <= nv(g)

function Graphs.has_edge(g::GridGraph, s, d)
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = index_to_coord(g, s)
        id, jd = index_to_coord(g, d)
        return has_edge_coord(g, is, js, id, jd)
    else
        return false
    end
end

function Graphs.outneighbors(g::GridGraph, s)
    is, js = index_to_coord(g, s)
    return (coord_to_index(g, id, jd) for (id, jd) in outneighbors_coord(g, is, js))
end

function Graphs.inneighbors(g::GridGraph, d)
    id, jd = index_to_coord(g, d)
    return (coord_to_index(g, is, js) for (is, js) in inneighbors_coord(g, id, jd))
end

function Graphs.edges(g::GridGraph)
    return (Edge(s, d) for s in vertices(g) for d in outneighbors(g, s))
end

function Graphs.ne(g::GridGraph)
    if all_active(g)
        if directions(g) == QUEEN_DIRECTIONS
            return ne_queen(g)
        elseif directions(g) == QUEEN_DIRECTIONS_PLUS_CENTER
            return ne_queen(g) + nv(g)
        elseif directions(g) == QUEEN_DIRECTIONS_ACYCLIC
            return ne_queen_acyclic(g)
        elseif directions(g) == ROOK_DIRECTIONS
            return ne_rook(g)
        elseif directions(g) == ROOK_DIRECTIONS_PLUS_CENTER
            return ne_rook(g) + nv(g)
        elseif directions(g) == ROOK_DIRECTIONS_ACYCLIC
            return ne_rook_acyclic(g)
        else
            return ne_generic(g)
        end
    else
        return ne_generic(g)
    end
end

function Graphs.weights(g::GridGraph{R}) where {R}
    V, E = nv(g), ne(g)
    colptr = Vector{Int}(undef, V + 1)
    rowval = Vector{Int}(undef, E)
    nzval = Vector{R}(undef, E)
    k = 1
    for s in vertices(g)
        colptr[s] = k
        for d in outneighbors(g, s)
            rowval[k] = d
            nzval[k] = edge_weight(g, s, d)
            k += 1
        end
    end
    colptr[end] = k
    return transpose(SparseMatrixCSC(V, V, colptr, rowval, nzval))
end

## Coord functions

has_vertex_coord(g::GridGraph, i, j) = 1 <= i <= height(g) && 1 <= j <= width(g)

function has_edge_coord(g::GridGraph, is, js, id, jd; check_direction=true)
    if !has_vertex_coord(g, is, js) || !has_vertex_coord(g, id, jd)
        return false
    elseif !vertex_active_coord(g, is, js) || !vertex_active_coord(g, id, jd)
        return false
    else
        if check_direction && !has_direction_coord(g, id - is, jd - js)  # invalid direction
            return false
        elseif (is == id) || (js == jd)  # same column or row
            return true
        elseif nb_corners_for_diag(g) == 0
            return true
        elseif nb_corners_for_diag(g) == 1
            return vertex_active_coord(g, is, jd) || vertex_active_coord(g, id, js)
        elseif nb_corners_for_diag(g) == 2
            return vertex_active_coord(g, is, jd) && vertex_active_coord(g, id, js)
        end
    end
end

function outneighbors_coord(g::GridGraph, is, js)
    # directions are listed in column major order
    candidates = ((is, js) + dir for dir in directions(g))
    return (
        (id, jd) for
        (id, jd) in candidates if has_edge_coord(g, is, js, id, jd; check_direction=false)
    )
end

function inneighbors_coord(g::GridGraph, id, jd)
    # directions are listed in column major order
    candidates = ((id, jd) - dir for dir in reverse(directions(g)))
    return (
        (is, js) for
        (is, js) in candidates if has_edge_coord(g, is, js, id, jd; check_direction=false)
    )
end

## Weights

"""
    edge_weight(g, s, d)

Compute the weight of the edge from `s` to `d`.

Only use this on edges that are guaranteed to exist.
"""
function edge_weight(g::GridGraph, s, d)
    if pythagoras_cost_for_diag(g)
        return edge_weight_corner(g, s, d)
    else
        return vertex_weight(g, d)
    end
end

function edge_weight_corner(g::GridGraph{R}, s, d) where {R}
    d_weight = vertex_weight(g, d)
    is, js = index_to_coord(g, s)
    id, jd = index_to_coord(g, d)
    if (is == id) || (js == jd)  # same row or column
        weight = d_weight
    else  # go through the cheapest corner and use Pythagoras
        weight = typemax(R)
        if vertex_active_coord(g, id, js)  # try first corner
            c_weight = vertex_weight_coord(g, id, js)
            weight = min(weight, convert(R, sqrt(c_weight^2 + d_weight^2)))
        end
        if vertex_active_coord(g, is, jd)  # try second corner
            c_weight = vertex_weight_coord(g, is, jd)
            weight = min(weight, convert(R, sqrt(c_weight^2 + d_weight^2)))
        end
    end
    return weight
end

## Edge counting

function ne_generic(g::GridGraph)
    counter = 0
    for u in vertices(g)
        for _ in outneighbors(g, u)
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

## Slow weights

function slow_weights(g::GridGraph{R}) where {R}
    E = ne(g)
    I = Vector{Int}(undef, E)
    J = Vector{Int}(undef, E)
    V = Vector{R}(undef, E)
    for (k, ed) in enumerate(edges(g))
        s, d = src(ed), dst(ed)
        I[k] = d
        J[k] = s
        V[k] = edge_weight(g, s, d)
    end
    return transpose(sparse(I, J, V, nv(g), nv(g)))
end
