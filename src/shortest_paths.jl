## Shortest path storage

"""
    ShortestPathTree{R<:Real}

Storage for the result of a single-source shortest paths query with source `s`.

# Fields
- `parents::Vector{Int}`: the parent of each vertex `v` in a shortest `s -> v` path.
- `dists::Vector{R}`: the distance of each vertex `v` from `s`.
"""
struct ShortestPathTree{R}
    parents::Vector{Int}
    dists::Vector{R}
end

"""
    get_path(spt::ShortestPathTree, s, d)

Reconstruct the shortest `s -> d` path from a `ShortestPathTree` with source `s`.
"""
function get_path(spt::ShortestPathTree, s, d)
    parents = spt.parents
    v = d
    path = [v]
    while v != s
        v = parents[v]
        if v == 0
            return Int[]
        else
            pushfirst!(path, v)
        end
    end
    return path
end

"""
    path_to_matrix(g::GridGraph, path::Vector{<:Integer})

Store the shortest `s -> d` path in `g` as an integer matrix of size `height(g) * width(g)`, where entry `(i,j)` counts the number of visits to the associated vertex.
"""
function path_to_matrix(g::GridGraph, path::Vector{<:Integer})
    y = zeros(Int, height(g), width(g))
    for v in path
        i, j = index_to_coord(g, v)
        y[i, j] += 1
    end
    return y
end

## Topological sort

"""
    grid_topological_sort(g, s)

Apply the topological sort on an acyclic `GridGraph` `g`, and return a `ShortestPathTree` with source `s`.

Assumes vertex indices correspond to topological ranks. Compatible with ForwardDiff.
"""
function grid_topological_sort(g::GridGraph{R}, s) where {R}
    @assert is_acyclic(g)
    # Init storage
    parents = zeros(Int, nv(g))
    dists = Vector{Union{Nothing,R}}(undef, nv(g))
    fill!(dists, nothing)
    # Add source
    dists[s] = zero(R)
    # Main loop
    for v in vertices(g)
        for u in inneighbors(g, v)
            d_u = dists[u]
            if !isnothing(d_u)
                d_v = dists[v]
                d_v_through_u = d_u + edge_weight(g, u, v)
                if isnothing(d_v) || (d_v_through_u < d_v)
                    dists[v] = d_v_through_u
                    parents[v] = u
                end
            end
        end
    end
    return ShortestPathTree(parents, dists)
end

"""
    grid_topological_sort(g, s, d)

Apply [`grid_topological_sort(g, s)`](@ref) and retrieve the shortest path from `s` to `d`.
"""
function grid_topological_sort(g::GridGraph, s, d)
    spt = grid_topological_sort(g, s)
    return get_path(spt, s, d)
end

## Dijkstra

"""
    grid_dijkstra(g, s)

Apply Dijkstra's algorithm on an `GridGraph` `g`, and return a `ShortestPathTree` with source `s`.

Uses a `DataStructures.BinaryHeap` internally instead of a `DataStructures.PriorityQueue`. Compatible with ForwardDiff.
"""
function grid_dijkstra(g::GridGraph{R}, s) where {R}
    @assert !has_negative_weights(g)
    # Init storage
    heap = BinaryHeap(Base.By(last), Pair{Int,R}[])
    parents = zeros(Int, nv(g))
    dists = Vector{Union{Nothing,R}}(undef, nv(g))
    fill!(dists, nothing)
    # Add source
    dists[s] = zero(R)
    push!(heap, s => zero(R))
    # Main loop
    while !isempty(heap)
        u, d_u = pop!(heap)
        if d_u <= dists[u]
            dists[u] = d_u
            for v in outneighbors(g, u)
                d_v = dists[v]
                d_v_through_u = d_u + edge_weight(g, u, v)
                if isnothing(d_v) || (d_v_through_u < d_v)
                    dists[v] = d_v_through_u
                    parents[v] = u
                    push!(heap, v => d_v_through_u)
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
function grid_dijkstra(g::GridGraph, s, d)
    spt = grid_dijkstra(g, s)
    return get_path(spt, s, d)
end

## Bellman-Ford

"""
    grid_bellman_ford(g, s)

Apply the Bellman-Ford algorithm on an `GridGraph` `g`, and return a `ShortestPathTree` with source `s`.

Compatible with ForwardDiff.
"""
function grid_bellman_ford(g::GridGraph{R}, s) where {R}
    # Init storage
    parents = zeros(Int, nv(g))
    dists = Vector{Union{Nothing,R}}(undef, nv(g))
    fill!(dists, nothing)
    # Add source
    dists[s] = zero(R)
    # Main loop
    for _ in 1:nv(g)
        for v in vertices(g)
            for u in inneighbors(g, v)
                d_u = dists[u]
                if !isnothing(d_u)
                    d_v = dists[v]
                    d_v_through_u = d_u + edge_weight(g, u, v)
                    if isnothing(d_v) || (d_v_through_u < d_v)
                        dists[v] = d_v_through_u
                        parents[v] = u
                    end
                end
            end
        end
    end
    return ShortestPathTree(parents, dists)
end

"""
    grid_bellman_ford(g, s, d)

Apply [`grid_bellman_ford(g, s)`](@ref) and retrieve the shortest path from `s` to `d`.
"""
function grid_bellman_ford(g::GridGraph, s, d)
    spt = grid_bellman_ford(g, s)
    return get_path(spt, s, d)
end
