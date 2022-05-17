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

## Dijkstra

"""
    grid_dijkstra!(queue, g, s; naive)

Apply Dijkstra's algorithm on an [`AbstractGridGraph`](@ref) `g`, and return a [`ShortestPathTree`](@ref) with source `s`.

The first argument is the priority `queue` used (and modified) during the algorithm.
When the keyword argument `naive` is set to true, priority updates are disabled and vertices may instead be inserted several times into the queue.
"""
function grid_dijkstra!(
    queue::Q, g::AbstractGridGraph{T,R}, s::Integer; naive::Bool=false
) where {Q,T,R<:AbstractFloat}
    @assert !has_negative_weights(g)
    dists = fill(typemax(R), nv(g))
    parents = zeros(T, nv(g))
    dists[s] = zero(R)
    enqueue!(queue, s, zero(R))
    while !isempty(queue)
        u = dequeue!(queue)
        d_u = dists[u]
        for v in outneighbors(g, u)
            dist_through_u = d_u + get_weight(g, v)
            if dist_through_u < dists[v]
                dists[v] = dist_through_u
                parents[v] = u
                if naive
                    enqueue!(queue, v, dist_through_u)
                else
                    queue[v] = dist_through_u
                end
            end
        end
    end
    return ShortestPathTree(parents, dists)
end

"""
    grid_dijkstra(g, s; naive)

Apply [`grid_dijkstra!(queue, g, s; naive)`](@ref) to a queue of type `DataStructures.PriorityQueue`.
"""
function grid_dijkstra(g::AbstractGridGraph{T,R}, s::Integer; naive::Bool=false) where {T,R}
    queue = PriorityQueue{T,R}()
    return grid_dijkstra!(queue, g, s; naive=naive)
end

"""
    grid_dijkstra(g, s, d; naive)

Apply [`grid_dijkstra(g, s; naive)`](@ref) and retrieve the shortest path from `s` to `d`.
"""
function grid_dijkstra(
    g::AbstractGridGraph{T,R}, s::Integer, d::Integer; naive::Bool=false
) where {T,R}
    spt = grid_dijkstra(g, s; naive=naive)
    return get_path(spt, s, d)
end

## Topological sort

"""
    grid_topological_sort(g, s)

Apply the topological sort on an acyclic [`AbstractGridGraph`](@ref) `g`, and return a [`ShortestPathTree`](@ref) with source `s`.

Assumes vertex indices correspond to topological ranks.
"""
function grid_topological_sort(
    g::AbstractGridGraph{T,R}, s::Integer
) where {T,R<:AbstractFloat}
    @assert is_acyclic(g)
    dists = fill(typemax(R), nv(g))
    parents = zeros(T, nv(g))
    dists[s] = zero(R)
    for v in vertices(g)
        for u in inneighbors(g, v)
            dist_through_u = dists[u] + get_weight(g, v)
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

Assumes vertex indices correspond to topological ranks.
"""
function grid_topological_sort(g::AbstractGridGraph, s::Integer, d::Integer)
    spt = grid_topological_sort(g, s)
    return get_path(spt, s, d)
end
