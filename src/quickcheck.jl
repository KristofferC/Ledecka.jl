export choose, arbitrary, quickCheck
export PropertyFailedResult, PropertyPassedResult, ConditionUnmet

"""
Produce a function mapping (size, rng) which produces 
an instance of some type within a range. 
The range can be interpreted for a very broad /range/ 
of definitions. Lists, UnitRanges, StepRange are all 
good explains. 
"""
function choose end 

"""
Produce a function mapping (size, rng) to an instance 
of a supplied ValueType. Ideally satisfies the aribtrary 
laws for a type-specific probability of repeating elements 
to ensure that the data is morally random.

`size` should constrain the instance to some appropriate
measure of size. For example: Magnitude for a vector, 
string length, absolute value for intengers, number of nodes 
in a graph.... 

`rng` should be a source of randomness that can be used with 
calls to `rand(rng, ...)` For the most part this should be 
expected to be a MersenneTwister or other seeded psuedo random 
number generator. But you could easily imagine just using entropy 
from the `RandomDevice` on a machine."""
function arbitrary end 


"""
Runs a series of random tests defined by arbitrary value types 
for some property to find counterexamples of the property. 

For example, for a property definition such as 

```
property_list_reverses(x::Vector{Integer}) = x == reverse(reverse(x))
```

`quickCheck` will generate many instances of a Vector{Integer}, 
call the property `property_list_reverses` with those values,
and ensure that all executions evaluate to successes.

`quickCheck` calls all methods of the property function. 
This means that common invariants can share the same 
property definition for its interface or protocol, 
and then supply specific property methods which call
that common property method.

For example, `property_list_reverse` could be written as: 

```
property_list_reverses(x) = x == reverse(reverse(x))
```

and then tagged implementations of the property could note that it 
holds for given types: 
property_list_reverses(x::Vector{Integer}) = property_list_reverses(x)
"""
function quickCheck end

export TestFailure, PropertyFailedResult
abstract type TestFailure end
struct PropertyFailedResult <: TestFailure
method
fails::Int 
passes::Int
counterexamples
end


export TestSuccess, PropertyPassedResult
abstract type TestSuccess end
struct PropertyPassedResult <: TestSuccess
method
passes::Int
end 

export property_pass
property_pass(s::Bool) = s 
property_pass(::TestSuccess) = true 
property_pass(::TestFailure) = false 


export FailedPropertiesResults 
struct FailedPropertiesResults <:TestFailure
    failures
    passes
end
export PassedPropertiesResults
struct PassedPropertiesResults <: TestSuccess 
    passes
end


abstract type ConditionUnmet end 
struct ConditionUnmetResult <:ConditionUnmet end 

function types_to_generate(amethod)
    sig_type = amethod.sig 
    tuple(sig_type.parameters[2:end]...)
end

function generate_args(to_gen)
    all_arbitraries = Vector()
    for t in to_gen
        append!(all_arbitraries, [arbitrary(t)])
    end

    if any(arb -> isa(arb, ArbitraryFailed), all_arbitraries)
        # If we failed to obtain an arbitrary, return the first 
        # failure for now. Consider changing to a wrapper type 
        # that also is an ArbitraryFailed for consumption 
        # outside of the quickCheck callsite. 
        return [arb for arb in all_arbitraries if isa(arb, ArbitraryFailed)][1]
    end

    function generate(size,rng)
        vals = Vector()
        for arb in all_arbitraries
            arbitrary_instance = arb(size,rng)
            append!(vals, [arbitrary_instance])
        end
        return vals
    end

    return generate
end

function quickCheck(property::Function)
    size = 1337
    rand_seed = rand(RandomDevice(), 1:10000000)

    results = Vector() 
    for (i, method) in enumerate(methods(property))
        method_rng = MersenneTwister(rand_seed + i)
        method_res = quickCheck(size, method_rng, property, method)
        append!(results, [method_res])
    end

    if any(x->isa(x, TestFailure),results)
        return FailedPropertiesResults([x for x in results if isa(x,TestFailure)], [x for x in results if !isa(x, TestFailure)]) 
    end
    return PassedPropertiesResults(results)
end

# TODO: These printlns should be changed to the appropriate printing 
# method or convention used so that we can optionally run tests silently
function quickCheck(size, rand, func, property::Method, verbose=true)
    println("checking $(property)")

    to_generate = types_to_generate(property)
    generator = generate_args(to_generate)

    isa(generator, ArbitraryFailed) && return generator
    
    passes = 0 
    fails = 0 
    counterexamples = []
    for i in 1:100
        generated_args = generator(size,rand)

        # Evaluate the property 
        property_result = func(generated_args...) 
            
        if property_pass(property_result) 
            passes = passes + 1 
        else
            # We need to really accomodate more failure types, like arbitraryFailures 
            # and such. This interface should change but for now we're going to stay with it. 
            fails = fails + 1 
            
            if fails == 1
                println("Failure for property $(property)")
            end

            append!(counterexamples,[generated_args])

            if fails <= 5
                println("Counterexample: $(generated_args)")
            end
        end
    end

    if fails > 0
        PropertyFailedResult(property, fails, passes, counterexamples)
    else
        PropertyPassedResult(property, passes)
    end
end
