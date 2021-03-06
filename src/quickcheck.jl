export quickCheck

export PropertyFailedResult, PropertyPassedResult, ConditionUnmet

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

function Base.show(io::IO, x::PropertyFailedResult) 
    print(io,"❌(😭$(x.fails)|😊$(x.passes) $(x.method) CE: ")

    top_counter = x.counterexamples[1:min(5, length(x.counterexamples))]

    Base.show(io, top_counter)
    print(io, ")")
end

export TestSuccess, PropertyPassedResult
abstract type TestSuccess end
struct PropertyPassedResult <: TestSuccess
method
passes::Int
end 

function Base.show(io::IO, x::PropertyPassedResult)
    print(io, "✅")
end




export property_pass
property_pass(s::Bool) = s 
property_pass(::TestSuccess) = true 
property_pass(::TestFailure) = false 
property_pass(x::Any) = throw("property pass undefined for $(x)")


export FailedPropertiesResults 
struct FailedPropertiesResults <:TestFailure
    failures
    passes
end

function Base.show(io::IO, x::FailedPropertiesResults)
    print(io, "❌(😡 $(length(x.failures)) 🙂 $(length(x.passes)) Failures: ")
    print(io,x.failures)
    print(io, " Passes: ") 
    print(io,x.passes)
    print(io, ")")
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
    if any(arb -> isa(arb,ArbitraryFailed), all_arbitraries)
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
    
    method_rng = MersenneTwister(round(Int64, time()*1000))
    results = Vector() 
    for (i, method) in enumerate(methods(property))
        method_rng = MersenneTwister(round(Int64, time()*1000+ i))
        method_res = quickCheck(size, method_rng, property, method)
        append!(results, [method_res])
    end

    if any(x->!quickcheck_success(x),results)
        return FailedPropertiesResults([x for x in results if !quickcheck_success(x)],[x for x in results if quickcheck_success(x)]) 
    end
    return PassedPropertiesResults(results)
end

quickcheck_success(x::Bool) = x 
quickcheck_success(x::TestFailure) = false
quickcheck_success(x::TestSuccess) = true
quickcheck_success(x::ArbitraryFailed) = false




mutable struct PropertyExceptionResult 
    x
    exception
end

Ledecka.property_pass(::PropertyExceptionResult) = false

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
    shrink_args= false
    generated_args = []
    for i in 1:100
        generated_args = generator(size,rand)

        # Evaluate the property 
        property_result = try 
            func(generated_args...) 
        catch ee
            PropertyExceptionResult(generated_args, ee)
        end
            
        if property_pass(property_result) 
            passes = passes + 1 
        else
            # We need to really accomodate more failure types, like arbitraryFailures 
            # and such. This interface should change but for now we're going to stay with it. 
            fails = fails + 1 
            
            if fails == 1
                println("Failure for property $(property)")
            end

            founds = 0 
            shrunk_args = generated_args
            result_args = generated_args

            shrunk_property_result = property_result
            result_property_result = property_result
            # Shrink down the counterexample as small as we can
            shrink_attempts = 10
            for _ in 1:shrink_attempts
                inner_args = [shrink(arg)(size,rand) for arg in shrunk_args]
                property_result_inner = try 
                    func(inner_args...) 
                catch ee
                    PropertyExceptionResult(inner_args, ee)
                end
                if !property_pass(property_result_inner) 
                    founds = founds + 1
                    shrunk_args = inner_args
                    result_args = shrunk_args
                    shrunk_property_result = property_result_inner
                    result_property_result = shrunk_property_result
                end
            end

            append!(counterexamples,[(result_args, result_property_result)])
            if fails <= 5
                println("Counterexample: $(result_args)")
                println("Property result: $(result_property_result)")
            end
        end
    end

    if fails > 0
        PropertyFailedResult(property, fails, passes, counterexamples)
    else
        PropertyPassedResult(property, passes)
    end
end
