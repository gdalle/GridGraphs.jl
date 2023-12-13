"""
$(TYPEDEF)

Graph defined by a rectangular grid of vertices.

# Fields

$(TYPEDFIELDS)
"""
struct GridGraph{R<:Real,A<:AbstractMatrix{Bool},D<:NTuple{<:Any,GridDirection}} <:
       AbstractGraph{Int}
    "Number of rows in the grid."
    height::Int
    "Number of columns in the grid."
    width::Int
    "Active vertices can have edges, inactive vertices are isolated (they correspond to obstacles)."
    activities::A
    "Set of legal directions used to define edges."
    directions::D
    "Cost of a straight edge."
    straight_cost::R
    "Cost of a diagonal edge."
    diag_cost::R
    "Number of active corner vertices necessary for a diagonal edge to exist (`0`, `1` or `2`)."
    diag_corners::Int
end

function GridGraph(
    height,
    width;
    activities=Trues(height, width),
    directions=ROOK_DIRECTIONS,
    straight_cost=1,
    diag_cost=one(straight_cost),
    diag_corners=0,
)
    return GridGraph(
        height, width, activities, directions, straight_cost, diag_cost, diag_corners
    )
end

## Attribute access

height(g::GridGraph) = g.height
width(g::GridGraph) = g.width
activities(g::GridGraph) = g.activities
directions(g::GridGraph) = g.directions
straight_cost(g::GridGraph) = g.straight_cost
diag_cost(g::GridGraph) = g.diag_cost
diag_corners(g::GridGraph) = g.diag_corners

## Activity

"""
    vertex_active(g, v)
    vertex_active(g, i, j)

Check if a vertex is active.
"""
vertex_active(g::GridGraph, v::Integer) = activities(g)[v]
vertex_active(g::GridGraph, i::Integer, j::Integer) = activities(g)[i, j]

## Directions

"""
    direction_allowed(g, direction)
    direction_allowed(g, Δi, Δj)

Check if a direction is allowed for an edge.
"""
direction_allowed(g::GridGraph, dir::GridDirection) = dir in directions(g)

function direction_allowed(g::GridGraph, Δi::Integer, Δj::Integer)
    direction = get_direction(Δi, Δj)
    if isnothing(direction)
        return false
    else
        return direction_allowed(g, direction)
    end
end

## Indexing

"""
    coord_to_index(g, i, j)

Convert a grid coordinate tuple `(i,j)` into the index `v` of the associated vertex.
"""
function coord_to_index(g::GridGraph, i::Integer, j::Integer)
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
function index_to_coord(g::GridGraph, v::Integer)
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

function Base.show(io::IO, g::GridGraph)
    print(
        io,
        """
        GridGraph with size ($(height(g)), $(width(g))) and directions $(directions(g))
        """,
    )
    _show_with_braille_patterns(io, SparseMatrixCSC(activities(g)))
    return nothing
end
