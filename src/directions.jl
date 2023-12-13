"""
    GridDirection

Enum type for the 9 possible move directions on a 2-dimensional grid with square cells: `northwest`, `west`, `southwest`, `north`, `center`, `south`, `northeast`, `east`, `southeast`.

Various subsets of these directions are defined as constants.
They are based on an analogy with the game of chess:
- `QUEEN_DIRECTIONS`
- `ROOK_DIRECTIONS`
- `QUEEN_DIRECTIONS_PLUS_CENTER`
- `ROOK_DIRECTIONS_PLUS_CENTER`
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

const ROOK_DIRECTIONS = (west, north, south, east)
const ROOK_DIRECTIONS_PLUS_CENTER = (west, north, center, south, east)

const QUEEN_DIRECTIONS = (
    northwest, west, southwest, north, south, northeast, east, southeast
)
const QUEEN_DIRECTIONS_PLUS_CENTER = (
    northwest, west, southwest, north, center, south, northeast, east, southeast
)

"""
    get_tuple(dir)

Translate a `GridDirection` into a couple of grid steps in `{±1,0}`.
"""
function get_tuple(dir::GridDirection)
    if dir == northwest
        return (-1, -1)
    elseif dir == west
        return (0, -1)
    elseif dir == southwest
        return (+1, -1)
    elseif dir == north
        return (-1, 0)
    elseif dir == center
        return (0, 0)
    elseif dir == south
        return (+1, 0)
    elseif dir == northeast
        return (-1, +1)
    elseif dir == east
        return (0, +1)
    elseif dir == southeast
        return (+1, +1)
    end
    return nothing
end

"""
    get_direction(Δi, Δj)

Translate a couple of grid steps in `{±1,0}` into a `GridDirection`.
"""
function get_direction(Δi, Δj)
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

function Base.:+((i, j), dir::GridDirection)
    Δi, Δj = get_tuple(dir)
    return (i + Δi, j + Δj)
end
