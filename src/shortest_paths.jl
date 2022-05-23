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
function get_path(spt::ShortestPathTree{T}, s::Integer, d::Integer) where {T}
    parents = spt.parents
    v = d
    path = [v]
    while v != s
        v = parents[v]
        if v == zero(T)
            return T[]
        else
            pushfirst!(path, v)
        end
    end
    return path
end

## Dijkstra

"""
    grid_dijkstra(g, s)

Apply Dijkstra's algorithm on an [`AbstractGridGraph`](@ref) `g`, and return a [`ShortestPathTree`](@ref) with source `s`.

Uses a `DataStructures.BinaryHeap` internally instead of a `DataStructures.PriorityQueue`.
"""
function grid_dijkstra(
    g::AbstractGridGraph{T,R}, s::Integer
) where {T,R<:AbstractFloat}
    @assert !has_negative_weights(g)
    # Init storage
    heap = BinaryHeap(Base.By(last), Pair{T,R}[])
    dists = fill(typemax(R), nv(g))
    # Add source
    dists[s] = zero(R)
    parents = zeros(T, nv(g))
    push!(heap, s => zero(R))
    # Main loop
    while !isempty(heap)
        u, d_u = pop!(heap)
        if d_u <= dists[u]
            dists[u] = d_u
            for v in outneighbors(g, u)
                d_v = d_u + get_weight(g, v)
                if d_v < dists[v]
                    dists[v] = d_v
                    parents[v] = u
                    push!(heap, v => d_v)
                end
            end
        end
    end
    return ShortestPathTree(parents, dists)
end

"""
    grid_dijkstra(g, s, d)

Apply [`grid_dijkstra(g, s)`](@ref) and retrieve the shortest path from `s` to `d`.
"""
function grid_dijkstra(
    g::AbstractGridGraph{T,R}, s::Integer, d::Integer; naive::Bool=false
) where {T,R}
    spt = grid_dijkstra(g, s)
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

Apply [`grid_topological_sort(g, s)`](@ref) and retrieve the shortest path from `s` to `d`.
"""
function grid_topological_sort(g::AbstractGridGraph, s::Integer, d::Integer)
    spt = grid_topological_sort(g, s)
    return get_path(spt, s, d)
end
