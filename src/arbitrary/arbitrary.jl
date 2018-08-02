
using Random

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



function shrink end
#shrink(x::Any) = (size,rng)->x
export shrink



"""
Represents types of ways that a call to arbitrary() can fail. 
The most basic kind of failure is just that the arbitrary instance 
is undefined for a given type. (ArbitraryUndefined). 
You could imagine a whole host of more exotic failures, though.
"""
abstract type ArbitraryFailed end 

"""
Value to represent when an arbitrary instance is undefined. 
This is returned as default for calls to `arbitrary(::All)`
but could also be returned in cases where the arbitrary value 
is undefined for other reasons, like dividing by zero.
"""
struct ArbitraryUndefined <:ArbitraryFailed 
arbitrary_type
end

"""
Arbitrary implementations are undefined unless specified otherwise.
"""
arbitrary(s) = ArbitraryUndefined(s)


# ----- Law implementation for arbitrary 
struct SaturationRecord
    key
    rate
end

struct PassedSaturationTest 
    trials
    threshold 
end

struct FailedSaturationTest 
    saturated_records 
    trials
    threshold 
end

"""
Test that a function which evaluates with no arguments and 
produces a consistently comparable type value across multiple
invocations and evalutes wether or not the values are 
repeated no more often then a certain threshold. 
Since values over that threshold are overwhelming and stacked
up, like so many unwanted things in a grocery store, we 
call it "saturation."
"""
function test_rng_saturation_for(fn::Function, iterations=1337, saturation_percentage=0.05)
    generated_results = Dict() 

    upper_range = iterations
    # The random number is "saturated" when it is too clogged up 
    # with boring or repetitive values. Some repetition is okay 
    # since it's basically inevitable. But we want to know that 
    # at least some of our cases are interesting on average. 
    # This will vary from generator to generator basically 

    # TODO: I don't like this code at all. Fix and remove the 
    # technical debt that festers here. 

    for i in 1:upper_range
        result_to_index = nothing
        try 
            random_result = fn() 
            result_to_index = random_result
        catch err
            result_to_index = err
        end

        generated_results[result_to_index] = get(generated_results, result_to_index, 0)+1
    end


    saturated_keys = [] 
    for (key, value) in generated_results 
        if value/upper_range > saturation_percentage
            append!(saturated_keys, [SaturationRecord(key, value/upper_range)])
        end
    end

    if length(saturated_keys) > 0
        FailedSaturationTest(saturated_keys,iterations,saturation_percentage)
    else
        PassedSaturationTest(iterations, saturation_percentage) 
    end
end

# TODO: Nobody is ever going to need a size bigger that 1337 
ARBITRARY_LAW_DEFAULT_SIZE = 1337

struct LawPassed end
abstract type LawFailed end 
struct FailedSaturationLaw <: LawFailed
   failure_record 
end

function just_an(arb::Function)
    seed = round(Int64, time()*1000)
    rng = MersenneTwister(seed)
    return arb(seed,rng)
end
export just_an

"""
Implements the arbitrary saturation law. 
The general gist of this is that we live in a world 
saturated with advertising and blockchain startups. 
Saturation is thus a generally bad thing. We don't 
want our arbitrary to resemble the real world that 
well; we need diverse generated values.  

More seriously: For any run of `iterations` calls to 
the arbitrary for a given `ValueType` there should be no 
more than `threshold` repeated items. Otherwise it's saturated
and boring for testing. 

Why should a testing law like this be bundled with the actual 
source? because it's part of the interface for an arbitrary 
implementation, silly! This test is also suprisingly good 
at finding common RNG issues with generating test data, 
so it's great to have it commonly defined so that each 
implementer isn't tempted to try to define it themselves 
in their own test code. 
"""
function arbitrary_saturation_law(::Type{ValueType}, iterations, threshold) where ValueType 
    # We want to define a basic function which binds the arbitrary
    get_rand_seed = ()->round(Int64, time()*1000)

    arb_value = arbitrary(ValueType)

    first_arb_result = just_an(arb_value)
    if typeof(first_arb_result) <: ArbitraryFailed 
        return FailedSaturationLaw(first_arb_result)     
    end



    function gen_arb_fn()
        size = ARBITRARY_LAW_DEFAULT_SIZE
        rng = MersenneTwister(get_rand_seed())
        () -> arb_value(size, rng)
    end

    result = test_rng_saturation_for(gen_arb_fn, iterations, threshold)

    r!(x::PassedSaturationTest) = LawPassed() 
    r!(x::FailedSaturationTest) = FailedSaturationLaw(x)     
    r!(result)
end



export arbitrary_saturation_law, arbitrary_saturation_law!, LawPassed, LawFailed, FailedSaturationLaw
export ArbitraryFailed, ArbitraryUndefined 
export arbitrary, choose 

arbitrary(::Type{Nothing}) = (size,rng) -> nothing
shrink(::Nothing) = (size,rng) -> nothing

arbitrary(::Type{Missing}) = (size, rng) -> missing
shrink(::Missing) = (size, rng) -> missing

