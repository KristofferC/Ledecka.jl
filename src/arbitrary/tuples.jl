
function Ledecka.arbitrary(::Type{NTuple{N, SomeType}}) where {N, SomeType}
    some_type_arb = arbitrary(SomeType)
    function arb(size, rng)
        values = [] 
        for _ in 1:N
            append!(values, some_type_arb(size,rng))
        end
        tuple(values...)
    end
    arb 
end


function Ledecka.arbitrary(tup::Type{X}) where X<:Tuple
    tuple_types = tup.types
    tuple_arbs = [arbitrary(tup_type) for tup_type in tuple_types]
    function arb(size, rng)
        tuple([tuple_arb(size,rng) for tuple_arb in tuple_arbs]...) 
    end
    arb
end



