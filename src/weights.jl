"""
    has_negative_weights(g)

Check whether there are any negative weights.
"""
function has_negative_weights(g::GridGraph{T,R}) where {T,R}
    return any(<(zero(R)), g.weights)
end

"""
    vertex_weight(g, v)

Retrieve the vertex weight associated with index `v`.
"""
vertex_weight(g::GridGraph, v::Integer) = g.weights[v]

"""
    vertex_weight_coord(g, i, j)

Retrieve the vertex weight associated with coordinates `(i, j)`.
"""
function vertex_weight_coord(g::GridGraph, i::Integer, j::Integer)
    v = coord_to_index(g, i, j)
    return vertex_weight(g, v)
end

function edge_weight(
    g::GridGraph{T,R,W,A,mt,md,direct}, s::Integer, d::Integer
) where {T,R,W,A,mt,md}
    return vertex_weight(g, d)
end

function edge_weight(
    g::GridGraph{T,R,W,A,mt,md,corner}, s::Integer, d::Integer
) where {T,R,W,A,mt,md}
    is, js = index_to_coord(g, s)
    id, jd = index_to_coord(g, d)
    return edge_weight_coord(g, is, js, id, jd)
end

function edge_weight_coord(
    g::GridGraph{T,R,W,A,mt,md,corner}, is::Integer, js::Integer, id::Integer, jd::Integer
) where {T,R,W,A,mt,md}
    dest_weight = vertex_weight_coord(g, id, jd)
    if is == id || js == jd
        return dest_weight
    else
        ic1, jc1 = id, js
        ic2, jc2 = is, jd
        c1_active = active_vertex_coord(g, ic1, jc1)
        c2_active = active_vertex_coord(g, ic2, jc2)
        if c1_active && c2_active
            c1_weight = vertex_weight_coord(g, ic1, jc1)
            c2_weight = vertex_weight_coord(g, ic2, jc2)
            return min(sqrt(c1_weight^2 + dest_weight^2), sqrt(c2_weight^2 + dest_weight^2))
        elseif c1_active
            c1_weight = vertex_weight_coord(g, ic1, jc1)
            return sqrt(c1_weight^2 + dest_weight^2)
        elseif c2_active
            c2_weight = vertex_weight_coord(g, ic2, jc2)
            return sqrt(c2_weight^2 + dest_weight^2)
        else
            return typemax(R)
        end
    end
end

"""
    Graphs.weights(g)

Compute a sparse matrix of edge weights based on the vertex weights.
"""
function Graphs.weights(g::GridGraph{T,R}) where {T,R}
    E = ne(g)
    I = Vector{T}(undef, E)
    J = Vector{T}(undef, E)
    V = Vector{R}(undef, E)
    for (k, ed) in enumerate(edges(g))
        s, d = src(ed), dst(ed)
        I[k] = s
        J[k] = d
        V[k] = edge_weight(g, s, d)
    end
    return sparse(I, J, V, nv(g), nv(g))
end
