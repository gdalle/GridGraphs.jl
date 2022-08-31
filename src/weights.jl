function edge_weight(g::GridGraph, s, d)
    if diag_through_corner(g)
        return edge_weight_direct(g, s, d)
    else
        return edge_weight_corner(g, s, d)
    end
end

function edge_weight_direct(g::GridGraph, s, d)
    d_weight = vertex_weight(g, d)
    return d_weight
end

function edge_weight_corner(g::GridGraph{T,R}, s, d) where {T,R}
    d_weight = vertex_weight(g, d)
    is, js = index_to_coord(g, s)
    id, jd = index_to_coord(g, d)
    if is == id || js == jd  # same row or column
        return d_weight
    else  # go through the cheapest corner and use Pythagoras
        ic1, jc1 = id, js
        ic2, jc2 = is, jd
        c1_active = active_vertex_coord(g, ic1, jc1)
        c2_active = active_vertex_coord(g, ic2, jc2)
        if c1_active && c2_active
            c1_weight = vertex_weight_coord(g, ic1, jc1)
            c2_weight = vertex_weight_coord(g, ic2, jc2)
            cmin_weight = min(c1_weight, c2_weight)
            return convert(R, sqrt(cmin_weight^2 + d_weight^2))
        elseif c1_active
            c1_weight = vertex_weight_coord(g, ic1, jc1)
            return convert(R, sqrt(c1_weight^2 + d_weight^2))
        elseif c2_active
            c2_weight = vertex_weight_coord(g, ic2, jc2)
            return convert(R, sqrt(c2_weight^2 + d_weight^2))
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
