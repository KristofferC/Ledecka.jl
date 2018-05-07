module CoreTests

using Test
using Random
using Ledecka

# The paper's example 

function reversi(x::AbstractArray{X,1}) where X
   if(length(x) >= 1)
        xs, ys = x[1], x[2:end]
        return vcat(promote(reversi(ys), reversi(xs))...)
   else
        return []
   end
end

reversi(x) = [x]

@test reversi([1,2,3]) == [3,2,1]

# properties of reversi 

property_rev_unit(x) = reversi([x]) == [x] # how to list compare in julia? 

function property_rev_app(xs::AbstractArray{X,1},
                               ys::AbstractArray{Y,1}) where {X,Y}
    reversi(vcat(promote(xs, ys)...)) == vcat(reversi(ys), reversi(xs))
end

property_rev_rev(xs::AbstractArray{X,1}) where X = reversi(reversi(xs)) == xs

# Properties do what we expect for some basic values 
@test property_rev_unit(1) == true 
@test property_rev_app([1,2], [3]) == true 
@test property_rev_app([1,2], []) == true 
@test property_rev_rev([1,2,3]) == true

test_one(s::Integer) = println("test one") 

our_only_test_one = first(methods(test_one))
@test (Integer,) == Ledecka.types_to_generate(our_only_test_one) 


function _some_property(x::Integer)
    if x < 10 
        return false
    else
        return true
    end
end

struct IntegerLessThan{X}
value
end

Ledecka.arbitrary(::Type{IntegerLessThan{X}}) where X = (s,r)->IntegerLessThan{X}(choose(Integer, -1337:X)(s,r))

function shrink(value::IntegerLessThan{X}) where X
    return IntegerLessThan{X}(shrink(value.value))  
end

function some_property(x::IntegerLessThan{100})
    if x.value > 100
        return false 
    else
        return true
    end
end


@testset "Core failure and passing scenarios" begin
passing_property_result = quickCheck(some_property)
@test isa(passing_property_result, PassedPropertiesResults) 
@test length(passing_property_result.passes) == 1 
@test isa(passing_property_result.passes[1], PropertyPassedResult)

failing_property_result = quickCheck(_some_property)
@test isa(failing_property_result, FailedPropertiesResults) 
@test length(failing_property_result.failures) > 0 
@test all(x->isa(x,TestFailure), failing_property_result.failures)
end


end
