module CheckersExample 

# Checkers.jl (a wonderfully written library) has an example 
# which ledecka can do just as well, just differently!
using Ledecka
using Test 

f(x) = x^2

function square_property(x::IntegerIn{-10:10})
    f(x.value) >= 0 
end


@testset "checkers example" begin
result = quickCheck(square_property) 
@test isa(result, TestSuccess)
end

# Checkers' call pattern for this case would be this macro;
# @test_formany -10<x<10, f(x) >= 0
# Our differences in opinion, summarized: 
# -> In Checkers, the property and its range to be tested across
#    are represented with a macro, and the test library does most
#    of its work parsing this macro structure to create test code
# -> In Checkers, the bounds for testing values are generated 
#    by parsing that macro and constrained to numeric types. 
# -> Checkers handles the call to the function under test and 
#    produces values that match the condition. 

# -> In Ledecka, we express each property to be tested as a 
#    function, with the types of the parameters for each of its 
#    methods defining what types of arbitrary values are 
#    generated
# -> In Ledecka, we must represent Integers generated within a 
#    range as a distinct type, and the property must be defined
#    in these terms. This leads to some weird call patterns, 
#    but we have to put up with it because multiple dispatch. ;)
# -> In Ledecka, generation of values is handled by arbitrary()
#    implementations, similar to how arbitrary type classes are 
#    defined in the O.G. quickCheck library, but the main 
#    difference is that Ledecka doesn't have nicely composable
#    monad types with some of the bind() machinery in place.
#    This makes some of the arbtirary instances harder to read.
# -> Read my lips: No. New. Macros. 

end

