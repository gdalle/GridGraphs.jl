"""
    path_to_matrix(g::AbstractGridGraph, path::Vector{<:Integer})

Store the shortest `s -> d` path in `g` as a binary matrix of size `height(g) * width(g)`, where ones correspond to visited vertices.
"""
function path_to_matrix(g::AbstractGridGraph, path::Vector{<:Integer})
    y = zeros(Bool, height(g), width(g))
    for v in path
        i, j = node_coord(g, v)
        y[i, j] = true
    end
    return y
end
