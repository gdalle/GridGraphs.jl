"""
    GridDirection

Enum type for the 9 possible move directions on a 2-dimensional grid with square cells: `northwest`, `west`, `southwest`, `north`, `center`, `south`, `northeast`, `east`, `southeast`.

Various subsets of these directions are defined as constants, but not exported. They are based on an analogy with the game of chess:
- `QUEEN_DIRECTIONS_PLUS_CENTER`
- `ROOK_DIRECTIONS_PLUS_CENTER`
- `QUEEN_DIRECTIONS`
- `ROOK_DIRECTIONS`
- `QUEEN_ACYCLIC_DIRECTIONS`
- `ROOK_ACYCLIC_DIRECTIONS`
Acyclic direction sets give rise to an acyclic graph because they are contained in `{south, east, southeast}`.
"""
@enum GridDirection northwest west southwest north center south northeast east southeast

function Base.show(io::IO, dir::GridDirection)
    if dir == northwest
        print(io, "NW")
    elseif dir == west
        print(io, "W")
    elseif dir == southwest
        print(io, "SW")
    elseif dir == north
        print(io, "N")
    elseif dir == center
        print(io, "C")
    elseif dir == south
        print(io, "S")
    elseif dir == northeast
        print(io, "NE")
    elseif dir == east
        print(io, "E")
    elseif dir == southeast
        print(io, "SE")
    end
end

const QUEEN_DIRECTIONS_PLUS_CENTER = (
    northwest, west, southwest, north, center, south, northeast, east, southeast
)
const ROOK_DIRECTIONS_PLUS_CENTER = (west, north, center, south, east)
const QUEEN_DIRECTIONS = (
    northwest, west, southwest, north, south, northeast, east, southeast
)
const QUEEN_ACYCLIC_DIRECTIONS = (south, east, southeast)
const ROOK_DIRECTIONS = (west, north, south, east)
const ROOK_ACYCLIC_DIRECTIONS = (south, east)

"""
    get_tuple(::Type{T}, dir)

Translate a `GridDirection` into a couple of grid steps in `{±1,0}` with integer type `T`.
"""
function get_tuple(::Type{T}, dir::GridDirection) where {T}
    if dir == northwest
        return (-one(T), -one(T))
    elseif dir == west
        return (zero(T), -one(T))
    elseif dir == southwest
        return (+one(T), -one(T))
    elseif dir == north
        return (-one(T), zero(T))
    elseif dir == center
        return (zero(T), zero(T))
    elseif dir == south
        return (+one(T), zero(T))
    elseif dir == northeast
        return (-one(T), +one(T))
    elseif dir == east
        return (zero(T), +one(T))
    elseif dir == southeast
        return (+one(T), +one(T))
    end
    return nothing
end

get_tuple(dir::GridDirection) = get_tuple(Int8, dir)

"""
    get_direction(Δi, Δj)

Translate a couple of grid steps in `{±1,0}` into a `GridDirection`.
"""
function get_direction(Δi::T, Δj::T) where {T}
    if Δj == -1
        if Δi == -1
            return northwest
        elseif Δi == 0
            return west
        elseif Δi == 1
            return southwest
        end
    elseif Δj == 0
        if Δi == -1
            return north
        elseif Δi == 0
            return center
        elseif Δi == 1
            return south
        end
    elseif Δj == 1
        if Δi == -1
            return northeast
        elseif Δi == 0
            return east
        elseif Δi == 1
            return southeast
        end
    end
    return nothing
end

"""
    Base.+((i, j), dir)

Add a `GridDirection` to a couple of grid coordinates and return the new coordinates.
"""
function Base.:+((i, j)::Tuple{T,T}, dir::GridDirection) where {T}
    Δi, Δj = get_tuple(T, dir)
    return (i + Δi, j + Δj)
end

"""
    Base.-(dir)

Compute the opposite `GridDirection` (e.g. `northwest` / `southeast`).
"""
function Base.:-(dir::GridDirection)
    Δi, Δj = get_tuple(dir)
    return get_direction(-Δi, -Δj)
end

"""
    Base.-((i, j), dir)

Subtract a `GridDirection` from a couple of grid coordinates and return the new coordinates.
"""
function Base.:-((i, j)::Tuple{T,T}, dir::GridDirection) where {T}
    return (i, j) + (-dir)
end

"""
    is_acyclic(directions)

Check if a set of directions is contained in `{south, east, southeast}`.
"""
function is_acyclic(directions::AbstractVector{GridDirection})
    return issubset(directions, QUEEN_ACYCLIC_DIRECTIONS)
end
