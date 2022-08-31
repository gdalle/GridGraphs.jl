@enum GridDirection northwest west southwest north center south northeast east southeast

const queen_directions = (
    northwest, west, southwest, north, south, northeast, east, southeast
)
const queen_acyclic_directions = (south, east, southeast)
const rook_directions = (west, north, south, east)
const rook_acyclic_directions = (south, east)

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
    else
        return (+one(T), +one(T))
    end
end

get_tuple(dir::GridDirection) = get_tuple(Int8, dir)

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
end

function Base.:+((i, j)::Tuple{T,T}, dir::GridDirection) where {T}
    Δi, Δj = get_tuple(T, dir)
    return (i + Δi, j + Δj)
end

function Base.:-(dir::GridDirection)
    Δi, Δj = get_tuple(dir)
    return get_direction(-Δi, -Δj)
end

function Base.:-((i, j)::Tuple{T,T}, dir::GridDirection) where {T}
    return (i, j) + (-dir)
end

function is_acyclic(directions::AbstractVector{GridDirection})
    return issubset(directions, queen_acyclic_directions)
end
