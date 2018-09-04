function choose_size(size_type, range)
    function arb(size, rng)
        chance = choose(Integer,0:10)(size,rng)
        if chance < 3
            return 0
        else
            return choose(size_type, range)(size, rng)
        end
    end
    arb
end


function arbitrary(::Type{AbstractVector{X}}) where X
    arbitrary(Vector{X})
end


function arbitrary(::Type{Vector{X}}) where X 
    function arg(size, rng)
        # Intentionally making this small because I don't have 
        # shrinking yet. 
        vector_size = choose_size(Integer, 0:10)(size, rng)
        v = Vector{X}()
        if vector_size == 0
            return v
        end
        
        for i in 1:vector_size
            arbitrary_instance = arbitrary(X)
            arb_value = arbitrary_instance(size, rng)
            append!(v, [arb_value])
        end
        return v
    end
    arg
end

function shrink(x::Vector{X}) where X
    function shr(size, rng)
        vect_length = length(x)

        half_length = round(Integer, floor(vect_length/2))
        new_length = choose(Integer, 0:half_length)(size,rng)
        result = Vector{X}()
        for val in x[1:new_length]
            shrunk = shrink(val)(size,rng) 
            append!(result, [shrunk]) 
        end
        result
    end
    shr
end

