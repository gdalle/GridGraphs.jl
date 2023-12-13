Base.eltype(::GridGraph) = Int
Graphs.edgetype(::GridGraph) = Edge{Int}

Graphs.is_directed(::GridGraph) = false
Graphs.is_directed(::Type{<:GridGraph}) = false

Graphs.nv(g::GridGraph) = height(g) * width(g)
Graphs.vertices(g::GridGraph) = 1:nv(g)

Graphs.has_vertex(g::GridGraph, v::Integer) = 1 <= v <= nv(g)

function Graphs.has_edge(g::GridGraph, s::Integer, d::Integer)
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = index_to_coord(g, s)
        id, jd = index_to_coord(g, d)
        return has_edge_coord(g, is, js, id, jd)
    else
        return false
    end
end

function Graphs.neighbors(g::GridGraph, s::Integer)
    is, js = index_to_coord(g, s)
    return (coord_to_index(g, id, jd) for (id, jd) in neighbors_coord(g, is, js))
end

Graphs.outneighbors(g::GridGraph, d::Integer) = neighbors(g, d)
Graphs.inneighbors(g::GridGraph, d::Integer) = neighbors(g, d)

function Graphs.edges(g::GridGraph)
    return (Edge(s, d) for s in vertices(g) for d in neighbors(g, s) if d >= s)
end

function Graphs.ne(g::GridGraph)
    return sum(Int(d >= s) for s in vertices(g) for d in neighbors(g, s))
end

function Graphs.weights(g::GridGraph{R}) where {R}
    V, E = nv(g), ne(g)
    colptr = Vector{Int}(undef, V + 1)
    rowval = Vector{Int}(undef, E)
    nzval = Vector{R}(undef, E)
    k = 1
    for s in vertices(g)
        colptr[s] = k
        for d in neighbors(g, s)
            if d >= s
                rowval[k] = d
                nzval[k] = edge_weight(g, s, d)
                k += 1
            end
        end
    end
    colptr[end] = k
    return Symmetric(transpose(SparseMatrixCSC(V, V, colptr, rowval, nzval)))
end

## Coord functions

function has_vertex_coord(g::GridGraph, i::Integer, j::Integer)
    return 1 <= i <= height(g) && 1 <= j <= width(g)
end

function has_edge_coord(g::GridGraph, is::Integer, js::Integer, id::Integer, jd::Integer)
    if !has_vertex_coord(g, is, js) || !has_vertex_coord(g, id, jd)
        return false
    elseif !vertex_active(g, is, js) || !vertex_active(g, id, jd)
        return false
    elseif !direction_allowed(g, id - is, jd - js)  # invalid direction
        return false
    elseif (is == id) || (js == jd)  # same column or row
        return true
    elseif diag_corners(g) == 0
        return true
    elseif diag_corners(g) == 1
        return vertex_active(g, is, jd) || vertex_active(g, id, js)
    elseif diag_corners(g) == 2
        return vertex_active(g, is, jd) && vertex_active(g, id, js)
    end
end

function neighbors_coord(g::GridGraph, is::Integer, js::Integer)
    candidates = ((is, js) + dir for dir in directions(g))
    return ((id, jd) for (id, jd) in candidates if has_edge_coord(g, is, js, id, jd))
end

## Weights

"""
    edge_weight(g, s, d)

Compute the weight of the edge from `s` to `d`.

Only use this on edges that are guaranteed to exist.
"""
function edge_weight(g::GridGraph, s::Integer, d::Integer)
    is, js = index_to_coord(g, s)
    id, jd = index_to_coord(g, d)
    if is == id || js == jd
        return straight_cost(g)
    else
        return diag_cost(g)
    end
end
