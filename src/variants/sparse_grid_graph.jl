"""
    SparseGridGraph{T<:Integer,R<:Real}

Analogue of [`GridGraph`](@ref) in which only some vertices are selected.

For simplicity, we consider that all nodes of the grid exist, but only some are usable (i.e. linked to their neighbors), so that masked vertices are alone in their connected component.

# Fields
- `weights::Matrix{R}`: grid of vertex weights
- `mask::Matrix{Bool}`: grid of boolean values, in which `true` indicates that a vertex is usable
"""
struct SparseGridGraph{T<:Integer,R<:Real} <: AbstractGridGraph{T,R}
    weights::Matrix{R}
    mask::Matrix{Bool}
    ne::Int
end

function SparseGridGraph{T,R}(weights::Matrix{R}, mask::Matrix{Bool}) where {T,R}
    ne = 0
    h, w = size(weights)
    for i in 1:h, j in 1:w
        if mask[i, j]
            for (i2, j2) in (
                (i - 1, j - 1),  # top left
                (i, j - 1),  # left
                (i + 1, j - 1),  # bottom left
                (i - 1, j),  # top
                (i + 1, j),  # bottom
                (i - 1, j + 1),  # top right
                (i, j + 1),  # right
                (i + 1, j + 1),  # bottom right
            )
                if (1 <= i2 <= h) && (1 <= j2 <= w) && mask[i2, j2]
                    ne += 1
                end
            end
        end
    end
    return SparseGridGraph{T,R}(weights, mask, ne)
end

function SparseGridGraph(weights::Matrix{R}, mask::Matrix{Bool}) where {R}
    return SparseGridGraph{Int,R}(weights, mask)
end

Graphs.ne(g::SparseGridGraph) = g.ne

function Graphs.has_edge(g::SparseGridGraph{T}, s::Integer, d::Integer) where {T}
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = node_coord(g, s)
        id, jd = node_coord(g, d)
        # 8 neighbors max
        return (
            (abs(is - id) <= one(T)) &&
            (abs(js - jd) <= one(T)) &&
            (s != d) &&
            g.mask[is, js] &&
            g.mask[id, jd]
        )
    else
        return false
    end
end

function Graphs.outneighbors(g::SparseGridGraph{T}, s::Integer) where {T}
    h, w = height(g), width(g)
    is, js = node_coord(g, s)
    possible_neighbors = ( # listed in ascending index order!
        (is - one(T), js - one(T)),  # top left
        (is, js - one(T)),  # left
        (is + one(T), js - one(T)),  # bottom left
        (is - one(T), js),  # top
        (is + one(T), js),  # bottom
        (is - one(T), js + one(T)),  # top right
        (is, js + one(T)),  # right
        (is + one(T), js + one(T)),  # bottom right
    )
    neighbors = (
        node_index(g, id, jd) for (id, jd) in possible_neighbors if
        ((one(T) <= id <= h) && (one(T) <= jd <= w) && g.mask[is, js] && g.mask[id, jd])
    )
    return neighbors
end

Graphs.inneighbors(g::SparseGridGraph, d::Integer) = outneighbors(g, d)
