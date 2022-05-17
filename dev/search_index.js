var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = GridGraphs","category":"page"},{"location":"#GridGraphs.jl","page":"Home","title":"GridGraphs.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Welcome to the documentation for GridGraphs, a package made for efficient analysis of rectangular grid graphs.","category":"page"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Docstrings","page":"Home","title":"Docstrings","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Modules = [GridGraphs]","category":"page"},{"location":"#GridGraphs.AbstractGridGraph","page":"Home","title":"GridGraphs.AbstractGridGraph","text":"AbstractGridGraph{T<:Integer,R<:Real}\n\nAbstract supertype for grid graphs with vertices of type T and weights of type R.\n\nAll subtypes must have a field weights::Matrix{R}, whose size gives the size of the grid and whose entries correspond to vertex weights. The weight of an edge (s,d) is then defined as the weight of the vertex d.\n\nTo implement a concrete subtype G <: AbstractGridGraph, the following methods need to be defined (see the Graphs.jl docs):\n\nGraphs.ne(g::G)\nGraphs.has_edge(g::G, s, d)\nGraphs.outneighbors(g::G, s)\nGraphs.inneighbors(g::G, d)\n\n\n\n\n\n","category":"type"},{"location":"#GridGraphs.AcyclicGridGraph","page":"Home","title":"GridGraphs.AcyclicGridGraph","text":"AcyclicGridGraph{T<:Integer,R<:Real}\n\nConcrete subtype of AbstractGridGraph, in which we can move from a cell (i,j) to its bottom, right and bottom right neighbors only. This means the graph is acyclic.\n\nFields\n\nweights::Matrix{R}: grid of vertex weights\n\n\n\n\n\n","category":"type"},{"location":"#GridGraphs.GridGraph","page":"Home","title":"GridGraphs.GridGraph","text":"GridGraph{T<:Integer,R<:Real}\n\nConcrete subtype of AbstractGridGraph, in which we can move from a cell (i,j) to any of its 8 nearest neighbors (lateral, vertical and diagonal).\n\nFields\n\nweights::Matrix{R}: grid of vertex weights\n\n\n\n\n\n","category":"type"},{"location":"#GridGraphs.ShortestPathTree","page":"Home","title":"GridGraphs.ShortestPathTree","text":"ShortestPathTree{T<:Integer,R<:Real}\n\nStorage for the result of a single-source shortest paths query with source s.\n\nFields\n\nparents::Vector{T}: the parent of each vertex v in a shortest s -> v path.\ndists::Vector{R}: the distance of each vertex v from s.\n\n\n\n\n\n","category":"type"},{"location":"#Graphs.weights-Union{Tuple{AbstractGridGraph{T, R}}, Tuple{R}, Tuple{T}} where {T, R}","page":"Home","title":"Graphs.weights","text":"Graphs.weights(g)\n\nCompute a sparse matrix of edge weights based on the vertex weights.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.get_path-Tuple{GridGraphs.ShortestPathTree, Integer, Integer}","page":"Home","title":"GridGraphs.get_path","text":"get_path(spt::ShortestPathTree, s, d)\n\nReconstruct the shortest s -> d path from a ShortestPathTree with source s.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.get_weight-Union{Tuple{R}, Tuple{T}, Tuple{AbstractGridGraph{T, R}, Integer, Integer}} where {T, R}","page":"Home","title":"GridGraphs.get_weight","text":"get_weight(g, i, j)\n\nRetrieve the vertex weight associated with coordinates (i,j).\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.get_weight-Union{Tuple{R}, Tuple{T}, Tuple{AbstractGridGraph{T, R}, Integer}} where {T, R}","page":"Home","title":"GridGraphs.get_weight","text":"get_weight(g, v)\n\nRetrieve the vertex weight associated with index v.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.grid_dijkstra!-Union{Tuple{R}, Tuple{T}, Tuple{Q}, Tuple{Q, AbstractGridGraph{T, R}, Integer}} where {Q, T, R<:AbstractFloat}","page":"Home","title":"GridGraphs.grid_dijkstra!","text":"grid_dijkstra!(queue, g, s; naive)\n\nApply Dijkstra's algorithm on an AbstractGridGraph g, and return a ShortestPathTree with source s.\n\nThe first argument is the priority queue used (and modified) during the algorithm. When the keyword argument naive is set to true, priority updates are disabled and vertices may instead be inserted several times into the queue.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.grid_dijkstra-Union{Tuple{R}, Tuple{T}, Tuple{AbstractGridGraph{T, R}, Integer, Integer}} where {T, R}","page":"Home","title":"GridGraphs.grid_dijkstra","text":"grid_dijkstra(g, s, d; naive)\n\nApply grid_dijkstra(g, s; naive) and retrieve the shortest path from s to d.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.grid_dijkstra-Union{Tuple{R}, Tuple{T}, Tuple{AbstractGridGraph{T, R}, Integer}} where {T, R}","page":"Home","title":"GridGraphs.grid_dijkstra","text":"grid_dijkstra(g, s; naive)\n\nApply grid_dijkstra!(queue, g, s; naive) to a queue of type DataStructures.PriorityQueue.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.grid_topological_sort-Tuple{AbstractGridGraph, Integer, Integer}","page":"Home","title":"GridGraphs.grid_topological_sort","text":"grid_topological_sort(g, s, d)\n\nApply the topological sort algorithm on an AbstractGridGraph g, and return a vector containing the vertices on the shortest path from s to d.\n\nAssumes vertex indices correspond to topological ranks.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.grid_topological_sort-Union{Tuple{R}, Tuple{T}, Tuple{AbstractGridGraph{T, R}, Integer}} where {T, R<:AbstractFloat}","page":"Home","title":"GridGraphs.grid_topological_sort","text":"grid_topological_sort(g, s)\n\nApply the topological sort on an acyclic AbstractGridGraph g, and return a ShortestPathTree with source s.\n\nAssumes vertex indices correspond to topological ranks.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.has_negative_weights-Union{Tuple{AbstractGridGraph{T, R}}, Tuple{R}, Tuple{T}} where {T, R}","page":"Home","title":"GridGraphs.has_negative_weights","text":"has_negative_weights(g)\n\nCheck whether the graph g has any negative weight.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.height-Union{Tuple{AbstractGridGraph{T}}, Tuple{T}} where T","page":"Home","title":"GridGraphs.height","text":"height(g)\n\nCompute the height of the grid (number of rows).\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.is_acyclic-Tuple{AbstractGridGraph}","page":"Home","title":"GridGraphs.is_acyclic","text":"is_acyclic(g)\n\nCheck whether g contains cycles.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.node_coord-Union{Tuple{T}, Tuple{AbstractGridGraph{T}, Integer}} where T","page":"Home","title":"GridGraphs.node_coord","text":"node_coord(g, i, j)\n\nConvert a vertex index v into the associate tuple (i,j) of grid coordinates.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.node_index-Union{Tuple{T}, Tuple{AbstractGridGraph{T}, Integer, Integer}} where T","page":"Home","title":"GridGraphs.node_index","text":"node_index(g, i, j)\n\nConvert a grid coordinate tuple (i,j) into the index v of the associated vertex.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.path_to_matrix-Tuple{AbstractGridGraph, Vector{<:Integer}}","page":"Home","title":"GridGraphs.path_to_matrix","text":"path_to_matrix(g::AbstractGridGraph, path::Vector{<:Integer})\n\nStore the shortest s -> d path in g as an integer matrix of size height(g) * width(g), where entry (i,j) counts the number of visits to the associated vertex.\n\n\n\n\n\n","category":"method"},{"location":"#GridGraphs.width-Union{Tuple{AbstractGridGraph{T}}, Tuple{T}} where T","page":"Home","title":"GridGraphs.width","text":"width(g)\n\nCompute the width of the grid (number of columns).\n\n\n\n\n\n","category":"method"}]
}
