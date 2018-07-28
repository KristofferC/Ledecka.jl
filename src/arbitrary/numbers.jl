using Random

function shrink(s::Integer)
    # Always shrink towards zero
    function cls(size, rng)
        if s == 0
            return s
        end
        
        magnitude = abs(s) 
        upper = s
        origin = 0

        if s > origin
            upper = upper-1
        else
            upper = upper+1
        end
        
        if length(upper:origin) == 0 
            return origin
        end
        return rand(rng, upper:origin)
    end
    cls
end


function constrain(s::Integer) 
    function cls(size,rng)
        bound = s 
        if abs(s) > size
            if s > 0
                bound = size
            else
                bound = -size
            end
        end

        return shrink(bound)(size,rng)
    end
    cls
end

function constrain end

function constrain(s::UnitRange{<:Integer})
    function cls(size, rng)
        if length(s) <= size
            return s
        end
        
        current = UnitRange(constrain(s.start)(size,rng), constrain(s.stop)(size,rng))

        while length(current) > size
            current = UnitRange(constrain(current.start)(size, rng), constrain(current.stop)(size,rng))
        end

        return current
    end
    cls
end

function choose(::Type{X}, range) where X
    return (size_limit,rng)->rand(rng,range)
end

arbitrary(::Type{Integer}) = (size, rng) -> arbitrary(Int32)(size,rng)
arbitrary(::Type{X}) where X<:Integer = (size, rng) -> X(choose(X, typemin(X):typemax(X))(size,rng))

arbitrary(::Type{Bool}) = (size, rng) -> arbitrary(Integer)(size,rng)%2 == 0 
shrink(b::Bool) = (size,rng)-> false



ledecka_typemin(::Type{Float64}) = Float64(-1e100) 
ledecka_typemax(::Type{Float64}) = Float64(1e100)
ledecka_typemin(::Type{Float32}) = Float32(-1e30)
ledecka_typemax(::Type{Float32}) = Float32(1e30)
ledecka_typemin(::Type{Float16}) = Float16(-64503)
ledecka_typemax(::Type{Float16}) = Float16(64503)


# Realistically we need to return NaN and other weird 
# values more often. We can put that off for now. 
# TODO: improve this 
function arbitrary(::Type{X})where X<:AbstractFloat
    function arb(size,rng)
        minimum = ledecka_typemin(X)
        maximum = ledecka_typemax(X)
        range = maximum - minimum 
        X(minimum+range*rand(rng, X))
    end
    arb
end

struct IntegerIn{R}
    value::Integer
end

export IntegerIn

function arbitrary(::Type{IntegerIn{R}}) where R 
    function arb(size, rng)
        return IntegerIn{R}(choose(Integer, R)(size,rng))
    end
    arb
end
