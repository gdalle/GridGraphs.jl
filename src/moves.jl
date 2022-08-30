"""
    MoveType

Enum type with possible values `rook` (4 neighbors) or `queen` (8 neighbors).
"""
@enum MoveType rook queen

"""
    MoveDirection

Enum type with possible values `cyclic` (all possible directions) or `acyclic` (only down and right).
"""
@enum MoveDirection cyclic acyclic

"""
    MoveCost

Enum type with possible values `direct` (the edge weight is the weight of the destination) or `corner` (the edge weight follows Pythagoras' theorem).
"""
@enum MoveCost direct corner

function move_type(::GridGraph{T,R,W,A,mt,md,mc})::MoveType where {T,R,W,A,mt,md,mc}
    return mt
end

function move_direction(
    ::GridGraph{T,R,W,A,mt,md,mc}
)::MoveDirection where {T,R,W,A,mt,md,mc}
    return md
end

function move_cost(::GridGraph{T,R,W,A,mt,md,mc})::MoveCost where {T,R,W,A,mt,md,mc}
    return mc
end
