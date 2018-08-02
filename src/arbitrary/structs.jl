# There's an important difference between the arbitrary 
# pattern for most types and for custom structs. 
# We don't want to expose some base level arbitrary method
# that will catch all structs; that's what our 
# arbitrary(::Any) method does, and the appropriate thing to 
# do when there's not an arbitrary defined is to be honest 
# about it, not try to secretly delve into this struct 
# logic.

# of course, we still have a pretty good idea how we can generate 
# arbitrary instances of structs that you'd most likely be 
# interested in quickChecking. So, you'll create a "tag" 
# implementation of arbitrary which will delegate to 
# arbitrary_struct(s::X) which will do all of the reflection for
# you and generate the appropriate arbitrary instance to return

function arbitrary_struct(::Type{StructType}) where StructType
    
    field_arbitraries = Vector() 

    for field_name in fieldnames(StructType)
        field_type = fieldtype(StructType, field_name)
        arbitrary_instance = arbitrary(field_type) 
        
        # TODO: Realistically we want to expose the 
        # ArbitrayUndefined with more context that the
        # typed field lacks an arbirtary provider. 
        isa(arbitrary_instance, ArbitraryUndefined) && return arbitrary_instance 
        
        append!(field_arbitraries, [arbitrary_instance])
    end

    function arbs(size, rng)
        constructor_values = Vector() 
        
        for arb in field_arbitraries 
            value = arb(size, rng)
            # TODO: realistically this needs to handle 
            # The whole gamut of arbitrary failure modes. 
            # Deal with that someday soon. 
            isa(value, ArbitraryUndefined) && return value 
            
            append!(constructor_values, [value])

        end
        
        StructType(constructor_values...)
    end
    arbs
end

function shrink_struct(x::X) where X
    val = x
    field_values = []
    for field_name in fieldnames(X)
        field_value = getfield(val, field_name) 
        append!(field_values, [field_value])
    end

    function shr(size, rng)
        constructor_values = []
    
        for field_value in field_values
            shrunk_value = shrink(field_value)(size, rng)
            append!(constructor_values, [shrunk_value])
        end

        return X(constructor_values...)
    end
    shr
end
export shrink_struct



export arbitrary_struct
