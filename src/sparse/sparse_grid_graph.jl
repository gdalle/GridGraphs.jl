"""
    SparseGridGraph{T<:Integer,R}

Analogue of [`GridGraph`](@ref) in which only some vertices are active.

For simplicity, we consider that all nodes of the grid exist, but only some are usable (i.e. linked to their neighbors), so that masked vertices are alone in their connected component.

# Fields
- `weights::Matrix{R}`: grid of vertex weights
- `active::Matrix{Bool}`: grid of boolean values, in which `true` indicates that a vertex is active (i.e. can be used)
- `ne::Int`: number of edges, precomputed at construction

Note that for simplicity, inactive vertices still belong to the graph, but they are isolated from their neighbors.
"""
struct SparseGridGraph{T<:Integer,R} <: AbstractGridGraph{T,R}
    weights::Matrix{R}
    active::Matrix{Bool}
    ne::Int
end

Graphs.ne(g::SparseGridGraph) = g.ne

function has_edge_coord(
    (is, js)::NTuple{2,<:Integer}, (id, jd)::NTuple{2,<:Integer}, active::Matrix{Bool}
)
    among_eight_neighbors = abs(is - id) <= 1 && abs(js - jd) <= 1 && (is, js) != (id, jd)
    both_active = active[is, js] && active[id, jd]
    if among_eight_neighbors && both_active
        lateral_jump = is == js || id == jd
        diagonal_active = active[is, jd] || active[id, js]
        return lateral_jump || diagonal_active
    else
        return false
    end
end

function SparseGridGraph{T,R}(weights::Matrix{R}, active::Matrix{Bool}) where {T,R}
    ne = 0
    h, w = size(weights)
    for is in 1:h, js in 1:w
        for (id, jd) in grid_neighbors(is, js; h=h, w=w)
            if has_edge_coord((is, js), (id, jd), active)
                ne += 1
            end
        end
    end
    return SparseGridGraph{T,R}(weights, active, ne)
end

function SparseGridGraph{T,R}(
    weights::Vector{R}, active::Vector{Bool}, h::Integer, w::Integer
) where {T,R}
    return SparseGridGraph{T,R}(reshape(weights, h, w), reshape(active, h, w))
end

function SparseGridGraph(weights::Matrix{R}, active::Matrix{Bool}) where {R}
    return SparseGridGraph{Int,R}(weights, active)
end

function SparseGridGraph(
    weights::Vector{R}, active::Vector{Bool}, h::Integer, w::Integer
) where {R}
    return SparseGridGraph{Int,R}(weights, active, h, w)
end

active_vertex(g::SparseGridGraph, i::Integer, j::Integer) = g.active[i, j]
active_vertex(g::SparseGridGraph, v::Integer) = g.active[node_coord(g, v)...]

function Graphs.has_edge(g::SparseGridGraph{T}, s::Integer, d::Integer) where {T}
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = node_coord(g, s)
        id, jd = node_coord(g, d)
        return has_edge_coord((is, js), (id, jd), g.active)
    end
    return false
end

function Graphs.outneighbors(g::SparseGridGraph{T}, s::Integer) where {T}
    h, w = height(g), width(g)
    is, js = node_coord(g, s)
    neighbors = (
        node_index(g, id, jd) for (id, jd) in grid_neighbors(is, js; h=h, w=w) if
        has_edge_coord((is, js), (id, jd), g.active)
    )
    return neighbors
end

Graphs.inneighbors(g::SparseGridGraph, d::Integer) = outneighbors(g, d)
