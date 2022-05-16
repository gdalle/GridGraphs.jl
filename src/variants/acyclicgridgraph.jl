"""
    AcyclicGridGraph{T<:Integer,R<:Real}

Concrete subtype of [`AbstractGridGraph`](@ref), in which we can move from a cell `(i,j)` to its bottom, right and bottom right neighbors only. This means the graph is acyclic.

# Fields
- `weights::Matrix{R}`: grid of vertex weights
"""
struct AcyclicGridGraph{T<:Integer,R<:Real} <: AbstractGridGraph{T,R}
    weights::Matrix{R}
end

AcyclicGridGraph(weights::Matrix{R}) where {R} = AcyclicGridGraph{Int,R}(weights)

is_acyclic(g::AcyclicGridGraph) = true

function Graphs.ne(g::AcyclicGridGraph{T}) where {T}
    h, w = height(g), width(g)
    return (
        (h - 1) * (w - 1) * 3 +  # topleft rectangle
        (w - 1) * 1 +  # bottom row
        (h - 1) * 1  # bottom row
    )
end

function Graphs.has_edge(g::AcyclicGridGraph{T}, s::Integer, d::Integer) where {T}
    if has_vertex(g, s) && has_vertex(g, d)
        is, js = node_coord(g, s)
        id, jd = node_coord(g, d)
        return (s != d) && (0 <= id - is <= 1) && (0 <= jd - js <= 1)  # 3 neighbors max
    else
        return false
    end
end

function Graphs.outneighbors(g::AcyclicGridGraph{T}, s::Integer) where {T}
    h, w = height(g), width(g)
    i, j = node_coord(g, s)
    possible_neighbors = (  # listed in ascending index order!
        (i + one(T), j),  # bottom
        (i, j + one(T)),  # right
        (i + one(T), j + one(T)),  # bottom right
    )
    neighbors = (
        node_index(g, id, jd) for
        (id, jd) in possible_neighbors if (one(T) <= id <= h) && (one(T) <= jd <= w)
    )
    return neighbors
end

function Graphs.inneighbors(g::AcyclicGridGraph{T}, s::Integer) where {T}
    h, w = height(g), width(g)
    i, j = node_coord(g, s)
    possible_neighbors = (  # listed in ascending index order!
        (i - one(T), j - one(T)),  # top left
        (i, j - one(T)),  # left
        (i - one(T), j),  # top
    )
    neighbors = (
        node_index(g, id, jd) for
        (id, jd) in possible_neighbors if (one(T) <= id <= h) && (one(T) <= jd <= w)
    )
    return neighbors
end
