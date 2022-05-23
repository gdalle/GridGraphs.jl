"""
    AbstractGridGraph{T<:Integer,R<:Real}

Abstract supertype for grid graphs with vertices of type `T` and weights of type `R`.

All subtypes must have a field `weights::Matrix{R}`, whose size gives the size of the grid and whose entries correspond to vertex weights.
The weight of an edge `(s,d)` is then defined as the weight of the vertex `d`.

To implement a concrete subtype `G <: AbstractGridGraph`, the following methods need to be defined (see [the Graphs.jl docs](https://juliagraphs.org/Graphs.jl/dev/ecosystem/interface/)):

- `Graphs.ne(g::G)`
- `Graphs.has_edge(g::G, s, d)`
- `Graphs.outneighbors(g::G, s)`
- `Graphs.inneighbors(g::G, d)`
"""
abstract type AbstractGridGraph{T<:Integer,R<:Real} <: AbstractGraph{T} end

"""
    height(g)

Compute the height of the grid (number of rows).
"""
height(g::AbstractGridGraph{T}) where {T} = T(size(g.weights, 1))

"""
    width(g)

Compute the width of the grid (number of columns).
"""
width(g::AbstractGridGraph{T}) where {T} = T(size(g.weights, 2))

Base.size(g::AbstractGridGraph, args...) = size(g.weights, args...)

## Graphs interface

Base.eltype(::AbstractGridGraph{T}) where {T} = T
Graphs.edgetype(::AbstractGridGraph{T}) where {T} = Edge{T}

Graphs.is_directed(::AbstractGridGraph) = true
Graphs.is_directed(::Type{<:AbstractGridGraph}) = true

Graphs.nv(g::AbstractGridGraph{T}) where {T} = height(g) * width(g)
Graphs.vertices(g::AbstractGridGraph{T}) where {T} = one(T):nv(g)
Graphs.has_vertex(g::AbstractGridGraph{T}, v::Integer) where {T} = one(T) <= v <= nv(g)

function Graphs.edges(g::AbstractGridGraph)
    return (Edge(s, d) for s in vertices(g) for d in outneighbors(g, s))
end

## Functions to implement in concrete subtypes

Graphs.ne(::AbstractGridGraph) = error("Not implemented")
Graphs.has_edge(::AbstractGridGraph, ::Integer, ::Integer) = error("Not implemented")
Graphs.outneighbors(::AbstractGridGraph, ::Integer) = error("Not implemented")
Graphs.inneighbors(::AbstractGridGraph, ::Integer) = error("Not implemented")

"""
    is_acyclic(g)

Check whether `g` contains cycles.
"""
is_acyclic(::AbstractGridGraph) = false

## Indexing translators

"""
    node_index(g, i, j)

Convert a grid coordinate tuple `(i,j)` into the index `v` of the associated vertex.
"""
function node_index(g::AbstractGridGraph{T}, i::Integer, j::Integer) where {T}
    h, w = height(g), width(g)
    if (one(T) <= i <= h) && (one(T) <= j <= w)
        v = (j - one(T)) * h + (i - one(T)) + one(T)  # enumerate column by column
        return v
    else
        return zero(T)
    end
end

"""
    node_coord(g, v)

Convert a vertex index `v` into the associate tuple `(i,j)` of grid coordinates.
"""
function node_coord(g::AbstractGridGraph{T}, v::Integer) where {T}
    if has_vertex(g, v)
        h = height(g)
        j = (v - one(T)) ÷ h + one(T)
        # i = (v - one(T)) % h + one(T)
        i = (v - one(T)) - h * (j - one(T)) + one(T)
        return i, j
    else
        return (zero(T), zero(T))
    end
end

## Weights

"""
    get_weight(g, v)

Retrieve the vertex weight associated with index `v`.
"""
get_weight(g::AbstractGridGraph{T,R}, v::Integer) where {T,R} = g.weights[v]

"""
    get_weight(g, i, j)

Retrieve the vertex weight associated with coordinates `(i,j)`.
"""
get_weight(g::AbstractGridGraph{T,R}, i::Integer, j::Integer) where {T,R} = g.weights[i, j]

"""
    has_negative_weights(g)

Check whether the graph `g` has any negative weight.
"""
has_negative_weights(g::AbstractGridGraph{T,R}) where {T,R} = any(<(zero(R)), g.weights)

"""
    Graphs.weights(g)

Compute a sparse matrix of edge weights based on the vertex weights.
"""
function Graphs.weights(g::AbstractGridGraph{T,R}) where {T,R}
    E = ne(g)
    I = Vector{T}(undef, E)
    J = Vector{T}(undef, E)
    V = Vector{R}(undef, E)
    for (k, ed) in enumerate(edges(g))
        s, d = src(ed), dst(ed)
        I[k] = s
        J[k] = d
        V[k] = get_weight(g, d)
    end
    return sparse(I, J, V, nv(g), nv(g))
end

## Misc

Graphs.reverse(g::AbstractGridGraph) = error("Not implemented")
