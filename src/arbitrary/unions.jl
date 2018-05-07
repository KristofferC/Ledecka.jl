union_types(x::DataType) = [x]
function union_types(s::Type{Z}) where {X,Y,Z<:Union{X,Y}} 
    types = [] 
    append!(types, union_types(Z.a))
    append!(types, union_types(Z.b))
    return types
end

export union_types

function arbitrary(s::Type{Union{X,Y}}) where {X,Y}
    arb_union_types = union_types(s) 

    candidate_union_arbitraries = []
    for t in arb_union_types 
        union_arb = arbitrary(t)
        isa(union_arb, ArbitraryUndefined) && return 
        append!(candidate_union_arbitraries, [union_arb])
    end

    function arb(size, rng) 
        to_generate = choose(DataType,candidate_union_arbitraries)(size, rng)
        to_generate(size, rng)
    end
end
