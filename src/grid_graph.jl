"""
    GridGraph{
        R<:Real,
        W<:AbstractMatrix{R},
        A<:AbstractMatrix{Bool},
        D<:NTuple{<:Any,GridDirection}
    }

Graph defined by a rectangular grid of vertices.

# Fields

- `vertex_weights::W`: Vertex weight matrix used to define edge weights.
- `vertex_activities::A`: Vertex activity matrix. All the vertices on the grid exist, but only active vertices can have edges (inactive vertices are isolated, they correspond to obstacles).
- `directions::D`: Set of legal directions used to define edges.
- `nb_corners_for_diag::Int`: Number of active corner vertices necessary for a diagonal edge to exist. Can take the values `0`, `1` or `2`.
- `pythagoras_cost_for_diag::Bool`: Whether the weight of a diagonal edge is computed using the shortest of the active corner paths (`true`) or just the weight of the arrival vertex (`false`).

# Constructors

There is a user-friendly constructor with the following default values:

    GridGraph(
        vertex_weights;
        vertex_activities=Trues(size(weights)),
        directions=ROOK_DIRECTIONS,
        nb_corners_for_diag=0,
        pythagoras_cost_for_diag=false
    )
"""
struct GridGraph{
    R<:Real,W<:AbstractMatrix{R},A<:AbstractMatrix{Bool},D<:NTuple{<:Any,GridDirection}
} <: AbstractGraph{Int}
    vertex_weights::W
    vertex_activities::A
    directions::D
    nb_corners_for_diag::Int
    pythagoras_cost_for_diag::Bool

    function GridGraph(
        vertex_weights::W,
        vertex_activities::A,
        directions::D,
        nb_corners_for_diag,
        pythagoras_cost_for_diag,
    ) where {W,A,D}
        @assert size(vertex_weights) == size(vertex_activities)
        @assert issorted(directions)
        @assert nb_corners_for_diag in (0, 1, 2)
        if pythagoras_cost_for_diag
            @assert nb_corners_for_diag > 0
        end
        return new{eltype(W),W,A,D}(
            vertex_weights,
            vertex_activities,
            directions,
            nb_corners_for_diag,
            pythagoras_cost_for_diag,
        )
    end
end

function GridGraph(
    vertex_weights;
    vertex_activities=Trues(size(vertex_weights)),
    directions=ROOK_DIRECTIONS,
    nb_corners_for_diag=0,
    pythagoras_cost_for_diag=false,
)
    return GridGraph(
        vertex_weights,
        vertex_activities,
        directions,
        nb_corners_for_diag,
        pythagoras_cost_for_diag,
    )
end

## Attribute access

vertex_weights(g::GridGraph) = g.vertex_weights
vertex_activities(g::GridGraph) = g.vertex_activities
directions(g::GridGraph) = g.directions
nb_corners_for_diag(g::GridGraph) = g.nb_corners_for_diag
pythagoras_cost_for_diag(g::GridGraph) = g.pythagoras_cost_for_diag

## Size

"""
    height(g)

Compute the height of the grid (number of rows).
"""
height(g::GridGraph) = size(vertex_weights(g), 1)

"""
    width(g)

Compute the width of the grid (number of columns).
"""
width(g::GridGraph) = size(vertex_weights(g), 2)

## Weights

"""
    vertex_weight(g, v)

Retrieve the vertex weight associated with index `v`.
"""
vertex_weight(g::GridGraph, v) = vertex_weights(g)[v]
vertex_weight_coord(g::GridGraph, i, j) = vertex_weights(g)[i, j]
has_negative_weights(g::GridGraph) = minimum(vertex_weights(g)) < 0

## Activity

"""
    vertex_active(g, v)

Check if vertex `v` is active.
"""
vertex_active(g::GridGraph, v) = vertex_activities(g)[v]
vertex_active_coord(g::GridGraph, i, j) = vertex_activities(g)[i, j]
nb_active(g::GridGraph) = sum(vertex_activities(g))
all_active(g::GridGraph) = nb_active(g) == length(vertex_activities(g))

## Directions

"""
    has_direction(g, dir)

Check if direction `dir` is a valid edge direction.
"""
has_direction(g::GridGraph, dir::GridDirection) = dir in directions(g)

function has_direction_coord(g::GridGraph, Δi, Δj)
    dir = get_direction(Δi, Δj)
    return isnothing(dir) ? false : has_direction(g, dir)
end

is_acyclic(g::GridGraph) = is_acyclic(directions(g))

## Indexing

"""
    coord_to_index(g, i, j)

Convert a grid coordinate tuple `(i,j)` into the index `v` of the associated vertex.
"""
function coord_to_index(g::GridGraph, i, j)
    h, w = height(g), width(g)
    if (1 <= i <= h) && (1 <= j <= w)
        v = (j - 1) * h + (i - 1) + 1  # enumerate column by column
        return v
    else
        return 0
    end
end

"""
    index_to_coord(g, v)

Convert a vertex index `v` into the tuple `(i,j)` of associated grid coordinates.
"""
function index_to_coord(g::GridGraph, v)
    if has_vertex(g, v)
        h = height(g)
        j = (v - 1) ÷ h + 1
        i = (v - 1) - h * (j - 1) + 1
        return (i, j)
    else
        return (0, 0)
    end
end

## Pretty printing

function Base.show(io::IO, g::GridGraph{R,W,A}) where {R,W,A}
    print(
        io,
        """
        GridGraph with size ($(height(g)), $(width(g))).
        Weights matrix: $W
        Active matrix: $A
        Directions: $(directions(g))
        Nb corners for diagonal: $(nb_corners_for_diag(g))
        Pythagoras cost for diagonal: $(pythagoras_cost_for_diag(g))
        """,
    )
    if !all_active(g)
        _show_with_braille_patterns(io, SparseMatrixCSC(vertex_activities(g)))
    end
    return nothing
end
