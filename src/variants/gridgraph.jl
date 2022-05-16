"""
    GridGraph{T<:Integer,R<:Real}

Concrete subtype of [`AbstractGridGraph`](@ref), in which we can move from a cell `(i,j)` to any of its 8 nearest neighbors (lateral, vertical and diagonal).

# Fields
- `weights::Matrix{R}`: grid of vertex weights
"""
struct GridGraph{T<:Integer,R<:Real} <: AbstractGridGraph{T,R}
    weights::Matrix{R}
end

GridGraph(weights::Matrix{R}) where {R} = GridGraph{Int,R}(weights)

is_acyclic(g::GridGraph) = false

function Graphs.ne(g::GridGraph{T}) where {T}
    h, w = height(g), width(g)
    return (
        (h - 2) * (w - 2) * 8 +  # central nodes
        2 * (h - 2) * 5 +  # vertical borders
        2 * (w - 2) * 5 +  # horizontal borders
        2 * 2 * 3  # corners
    )
end

function Graphs.has_edge(g::GridGraph{T}, s::Integer, d::Integer) where {T}
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = node_coord(g, s)
        id, jd = node_coord(g, d)
        return (s != d) && (abs(is - id) <= one(T)) && (abs(js - jd) <= one(T))  # 8 neighbors max
    else
        return false
    end
end

function Graphs.outneighbors(g::GridGraph{T}, s::Integer) where {T}
    h, w = height(g), width(g)
    i, j = node_coord(g, s)
    possible_neighbors = ( # listed in ascending index order!
        (i - one(T), j - one(T)),  # top left
        (i, j - one(T)),  # left
        (i + one(T), j - one(T)),  # bottom left
        (i - one(T), j),  # top
        (i + one(T), j),  # bottom
        (i - one(T), j + one(T)),  # top right
        (i, j + one(T)),  # right
        (i + one(T), j + one(T)),  # bottom right
    )
    neighbors = (
        node_index(g, id, jd) for
        (id, jd) in possible_neighbors if (one(T) <= id <= h) && (one(T) <= jd <= w)
    )
    return neighbors
end

Graphs.inneighbors(g::GridGraph, d::Integer) = outneighbors(g, d)
