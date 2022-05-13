struct VectorPriorityQueue{K,V}
    keys::Vector{K}
    values::Vector{V}
end

VectorPriorityQueue{K,V}() where {K,V} = VectorPriorityQueue{K,V}(K[], V[])

Base.first(pq::VectorPriorityQueue) = first(pq.keys)
Base.peek(pq::VectorPriorityQueue) = first(pq)
Base.length(pq::VectorPriorityQueue) = length(pq.keys)
Base.keys(pq::VectorPriorityQueue) = pq.keys
Base.haskey(pq::VectorPriorityQueue{K}, k::K) where {K} = k in keys(pq)
Base.values(pq::VectorPriorityQueue) = pq.values
Base.isempty(pq::VectorPriorityQueue) = isempty(pq.keys)
Base.pairs(pq::VectorPriorityQueue) = (k => v for (k, v) in zip(pq.keys, pq.values))

function DataStructures.enqueue!(pq::VectorPriorityQueue{K,V}, k::K, v::V) where {K,V}
    left = searchsortedfirst(pq.values, v)
    insert!(pq.keys, left, k)
    insert!(pq.values, left, v)
    return nothing
end

function DataStructures.dequeue!(pq::VectorPriorityQueue)
    k = popfirst!(pq.keys)
    popfirst!(pq.values)
    return k
end

function Base.deleteat!(pq::VectorPriorityQueue, args...)
    deleteat!(pq.keys, args...)
    deleteat!(pq.values, args...)
    return nothing
end

function Base.setindex!(pq::VectorPriorityQueue{K,V}, v::V, k::K) where {K,V}
    i = findfirst(isequal(k), pq.keys)
    if !isnothing(i)
        pq.values[i] = v
    else
        enqueue!(pq, k, v)
    end
end
