function arbitrary(::Type{Dict{X,Y}}) where {X,Y}
    function args(size, rng) 
        # Again, we want a better combinator for choosing 
        # sizes of collections that biases towards the empty 
        # collection. 
        entries = choose(Integer, 0:10)(size,rng)
        result = Dict{X,Y}()
        entries == 0 && return result 

        for i in 1:entries
            arbitrary_key = arbitrary(X)(size, rng)
            arbitrary_value = arbitrary(Y)(size, rng)
            result[arbitrary_key] = arbitrary_value
        end
        return result
    end
end
