"""
    GridDirection

Enum type for the 4 possible move directions on a 2-dimensional grid with square cells: `west`, `north`, `south`, `east`.
"""
@enum GridDirection west north south east

"""
    get_tuple(dir)

Translate a `GridDirection` into a couple of grid steps in `{±1,0}`.
"""
function get_tuple(dir::GridDirection)
    if dir == west
        return (0, -1)
    elseif dir == north
        return (-1, 0)
    elseif dir == south
        return (+1, 0)
    elseif dir == east
        return (0, +1)
    end
end

"""
    get_direction(Δi, Δj)

Translate a couple of grid steps in `{±1,0}` into a `GridDirection`.
"""
function get_direction(Δi::Integer, Δj::Integer)
    if Δi == 0 && Δj == -1
        return west
    elseif Δi == -1 && Δj == 0
        return north
    elseif Δi == 1 && Δj == 0
        return south
    elseif Δi == 0 && Δj == 1
        return east
    end
    return nothing
end

function Base.:+((i, j)::NTuple{2,Integer}, dir::GridDirection)
    Δi, Δj = get_tuple(dir)
    return (i + Δi, j + Δj)
end

function Base.:-(dir::GridDirection)
    Δi, Δj = get_tuple(dir)
    return get_direction(-Δi, -Δj)
end

function Base.:-((i, j)::NTuple{2,Integer}, dir::GridDirection)
    return (i, j) + (-dir)
end
