
function arbitrary(::Type{Vector{X}}) where X 
    function arg(size, rng)
        # Intentionally making this small because I don't have 
        # shrinking yet. 
        vector_size = choose(Integer, 0:10)(size, rng)
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

