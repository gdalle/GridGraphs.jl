"""
    edge_weight(g, s, d)

Compute the weight of the edge from `s` to `d`.

- If `diag_through_corner(g)` is `false`, return the vertex weight of the destination `d`
- If `diag_through_corner(g)` is `true`, use Pythagoras' theorem on the cheapest of the two corner vertices.

# See also

- [`edge_weight_direct(g, s, d)`](@ref)
- [`edge_weight_corner(g, s, d)`](@ref)
"""
function edge_weight(g::GridGraph, s, d)
    if diag_through_corner(g)
        return edge_weight_corner(g, s, d)
    else
        return edge_weight_direct(g, s, d)
    end
end

"""
    edge_weight_direct(g, s, d)
"""
function edge_weight_direct(g::GridGraph, s, d)
    d_weight = vertex_weight(g, d)
    return d_weight
end

"""
    edge_weight_corner(g, s, d)
"""
function edge_weight_corner(g::GridGraph{T,R}, s, d) where {T,R}
    d_weight = vertex_weight(g, d)
    is, js = index_to_coord(g, s)
    id, jd = index_to_coord(g, d)
    if (is == id) || (js == jd)  # same row or column
        return d_weight
    else  # go through the cheapest corner and use Pythagoras
        ic1, jc1 = id, js
        ic2, jc2 = is, jd
        if active_vertex_coord(g, ic1, jc1) && active_vertex_coord(g, ic2, jc2)
            c1_weight = vertex_weight_coord(g, ic1, jc1)
            c2_weight = vertex_weight_coord(g, ic2, jc2)
            cmin_weight = min(c1_weight, c2_weight)
            return convert(R, sqrt(cmin_weight^2 + d_weight^2))
        else
            return typemax(R)
        end
    end
end

"""
    Graphs.weights(g)

Efficiently compute a sparse matrix of edge weights based on the vertex weights.
"""
Graphs.weights(g::GridGraph) = fast_weights(g)

function slow_weights(g::GridGraph{T,R}) where {T,R}
    E = ne(g)
    I = Vector{T}(undef, E)
    J = Vector{T}(undef, E)
    V = Vector{R}(undef, E)
    for (k, ed) in enumerate(edges(g))
        s, d = src(ed), dst(ed)
        I[k] = d
        J[k] = s
        V[k] = edge_weight(g, s, d)
    end
    return transpose(sparse(I, J, V, nv(g), nv(g)))
end

function fast_weights(g::GridGraph{T,R}) where {T,R}
    V, E = nv(g), ne(g)
    colptr = Vector{T}(undef, V + 1)
    rowval = Vector{T}(undef, E)
    nzval = Vector{R}(undef, E)
    k = 1
    for s in vertices(g)
        colptr[s] = k
        active_vertex(g, s) || continue
        for d in outneighbors(g, s)
            rowval[k] = d
            nzval[k] = edge_weight(g, s, d)
            k += 1
        end
    end
    colptr[end] = k
    return transpose(SparseMatrixCSC(V, V, colptr, rowval, nzval))
end
