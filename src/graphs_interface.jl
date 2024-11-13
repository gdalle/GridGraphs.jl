Base.eltype(::GridGraph) = Int
Graphs.edgetype(::GridGraph) = Edge{Int}

Graphs.is_directed(::GridGraph) = true
Graphs.is_directed(::Type{<:GridGraph}) = true

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
    h, w = height(g), width(g)
    @assert h >= 2 && w >= 2
    inside_degree = 4
    border_degree = is_torus(g) ? 4 : 3
    corner_degree = is_torus(g) ? 4 : 2
    return (
        (h - 2) * (w - 2) * inside_degree +  # inside
        2 * (h - 2) * border_degree +  # vertical borders without corners
        2 * (w - 2) * border_degree +  # horizontal borders without corners
        4 * corner_degree  # corners
    )
end

function Graphs.weights(g::GridGraph{R}) where {R}
    # TODO: speed things up
    n = nv(g)
    E = edges(g)
    I = src.(E)
    J = dst.(E)
    W = edge_weight.(Ref(g), I, J)
    return sparse(I, J, W, n, n)
end

## Coord functions

function has_vertex_coord(g::GridGraph, i::Integer, j::Integer)
    return 1 <= i <= height(g) && 1 <= j <= width(g)
end

function has_edge_coord(g::GridGraph, is::Integer, js::Integer, id::Integer, jd::Integer)
    h, w = height(g), width(g)
    @assert has_vertex_coord(g, is, js) && has_vertex_coord(g, id, jd)
    if is_torus(g)
        i_ok = id == is || (
            if is == 1
                id == 2 || id == h
            elseif is == h
                id == h - 1 || id == 1
            else
                id == is - 1 || id == is + 1
            end
        )
        j_ok = jd == js || (
            if js == 1
                jd == 2 || jd == w
            elseif js == w
                jd == w - 1 || jd == 1
            else
                jd == js - 1 || jd == js + 1
            end
        )
        return i_ok && j_ok && (id == is || jd == js)
    else
        return abs(id - is) + abs(jd - js) == 1
    end
end

function outneighbors_coord(g::GridGraph, is::Integer, js::Integer)
    h, w = height(g), width(g)
    @assert has_vertex_coord(g, is, js)
    # directions are listed in column major order
    candidates = Ref((is, js)) .+ instances(GridDirection)
    if is_torus(g)
        return ((mod1(id, h), mod1(jd, w)) for (id, jd) in candidates)
    else
        return ((id, jd) for (id, jd) in candidates if has_vertex_coord(g, id, jd))
    end
end

function inneighbors_coord(g::GridGraph, id::Integer, jd::Integer)
    h, w = height(g), width(g)
    @assert has_vertex_coord(g, id, jd)
    # directions are listed in column major order
    candidates = Ref((id, jd)) .- reverse(instances(GridDirection))
    if is_torus(g)
        return ((mod1(is, h), mod1(js, w)) for (is, js) in candidates)
    else
        return ((is, js) for (is, js) in candidates if has_vertex_coord(g, is, js))
    end
end

## Weights

"""
    edge_weight(g, s, d)

Compute the weight of the edge from `s` to `d`.

Only use this on edges that are guaranteed to exist.
"""
edge_weight(g::GridGraph, s::Integer, d::Integer) = vertex_weight(g, d)
