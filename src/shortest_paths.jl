## Shortest path storage

"""
    ShortestPathTree{T<:Integer,R<:Real}

Storage for the result of a single-source shortest paths query with source `s`.

# Fields
- `parents::Vector{T}`: the parent of each vertex `v` in a shortest `s -> v` path.
- `dists::Vector{R}`: the distance of each vertex `v` from `s`.
"""
struct ShortestPathTree{T<:Integer,R<:Real}
    parents::Vector{T}
    dists::Vector{R}
end

"""
    get_path(spt::ShortestPathTree, s, d)

Reconstruct the shortest `s -> d` path from a [`ShortestPathTree`](@ref) with source `s`.
"""
function get_path(spt::ShortestPathTree, s::Integer, d::Integer)
    parents = spt.parents
    v = d
    path = [v]
    while v != s
        v = parents[v]
        pushfirst!(path, v)
    end
    return path
end

"""
    get_path_matrix(spt::ShortestPathTree, g::AbstractGridGraph, s, d)

Reconstruct the shortest `s -> d` path from a [`ShortestPathTree`](@ref) with source `s`, and store it as a binary matrix of size `height(g) * width(g)`.
"""
function get_path_matrix(
    spt::ShortestPathTree, g::AbstractGridGraph, s::Integer, d::Integer
)
    path = get_path(spt, s, d)
    y = zeros(Bool, height(g), width(g))
    for v in path
        i, j = node_coord(g, v)
        y[i, j] = true
    end
    return y
end

## Dijkstra

"""
    grid_dijkstra(g, s)

Apply Dijkstra's algorithm on an [`AbstractGridGraph`](@ref) `g`, and return a [`ShortestPathTree`](@ref) with source `s`.
"""
function grid_dijkstra(g::AbstractGridGraph{T,R}, s::Integer) where {T,R<:AbstractFloat}
    @assert !has_negative_weights(g)
    dists = fill(typemax(R), nv(g))
    parents = zeros(T, nv(g))
    Q = PriorityQueue{T,R}()
    dists[s] = zero(R)
    enqueue!(Q, s, zero(R))
    while !isempty(Q)
        u = dequeue!(Q)
        d_u = dists[u]
        for v in outneighbors(g, u)
            dist_through_u = d_u + get_weight(g, v)
            if dist_through_u < dists[v]
                dists[v] = dist_through_u
                parents[v] = u
                Q[v] = dist_through_u
            end
        end
    end
    return ShortestPathTree(parents, dists)
end

"""
    grid_dijkstra(g, s, d)

Apply Dijkstra's algorithm on an [`AbstractGridGraph`](@ref) `g`, and return a vector containing the vertices on the shortest path from `s` to `d`.
"""
function grid_dijkstra(g::AbstractGridGraph, s::Integer, d::Integer)
    spt = grid_dijkstra(g, s)
    return get_path(spt, s, d)
end

"""
    grid_dijkstra_dist(g, s, d)

Apply Dijkstra's algorithm on an [`AbstractGridGraph`](@ref) `g`, and return the shortest path distance from `s` to `d`.
"""
function grid_dijkstra_dist(g::AbstractGridGraph, s::Integer, d::Integer)
    spt = grid_dijkstra(g, s)
    return spt.dists[d]
end

## Topological sort

"""
    grid_topological_sort(g, s)

Apply the topological sort on an acyclic [`AbstractGridGraph`](@ref) `g`, and return a [`ShortestPathTree`](@ref) with source `s`.
"""
function grid_topological_sort(
    g::AbstractGridGraph{T,R}, s::Integer
) where {T,R<:AbstractFloat}
    @assert is_acyclic(g)
    dists = fill(typemax(R), nv(g))
    parents = zeros(T, nv(g))
    dists[s] = zero(R)
    for u in s:nv(g)
        d_u = dists[u]
        for v in outneighbors(g, u)
            dist_through_u = d_u + get_weight(g, v)
            if dist_through_u < dists[v]
                dists[v] = dist_through_u
                parents[v] = u
            end
        end
    end
    return ShortestPathTree(parents, dists)
end

"""
    grid_topological_sort(g, s, d)

Apply the topological sort algorithm on an [`AbstractGridGraph`](@ref) `g`, and return a vector containing the vertices on the shortest path from `s` to `d`.
"""
function grid_topological_sort_path(g::AbstractGridGraph, s::Integer, d::Integer)
    spt = grid_topological_sort(g, s)
    return get_path(spt, s, d)
end

"""
    grid_topological_sort_dist(g, s, d)

Apply the topological sort algorithm on an [`AbstractGridGraph`](@ref) `g`, and return the shortest path distance from `s` to `d`.
"""
function grid_topological_sort_dist(g::AbstractGridGraph, s::Integer, d::Integer)
    spt = grid_topological_sort(g, s)
    return spt.dists[d]
end

## TODO: Bellman-Ford
