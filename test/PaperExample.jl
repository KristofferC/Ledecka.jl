module PaperExample

using Ledecka
using Test 

# A basic reverse implmementation
function reversi(x::Vector{X}) where X
    if length(x) >= 1 
        xs, ys = x[1], x[2:end]
        return vcat(promote(reversi(ys), [xs])...)
    else
        return []
    end
end

# Properties for the reverse function. 
property_rev_unit(x::Integer) = reversi([x]) == [x]

function property_rev_applicative(xs::Vector{Integer}, ys::Vector{Integer})
    reversi(vcat(promote(xs,ys)...)) == vcat(reversi(ys),reversi(xs))
end

function property_rev_reverse(xs::Vector{Integer})
    reversi(reversi(xs)) == xs
end

@testset "quickCheck paper example" begin
@test property_rev_unit(5) == true

# This implementation should pass on all fronts. 
unit_result = quickCheck(property_rev_unit)
@test isa(unit_result, TestSuccess)

appl_result = quickCheck(property_rev_applicative)
@test isa(appl_result, TestSuccess)

rev_result = quickCheck(property_rev_reverse)
@test isa(rev_result, TestSuccess)

end
end
