"""
    path_to_matrix(g::AbstractGridGraph, path::Vector{<:Integer})

Store the shortest `s -> d` path in `g` as an integer matrix of size `height(g) * width(g)`, where entry `(i,j)` counts the number of visits to the associated vertex.
"""
function path_to_matrix(g::AbstractGridGraph, path::Vector{<:Integer})
    y = zeros(Int, height(g), width(g))
    for v in path
        i, j = node_coord(g, v)
        y[i, j] += 1
    end
    return y
end
