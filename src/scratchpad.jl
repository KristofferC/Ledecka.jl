using Base.Test
using Random

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

property_rev_rev{X}(xs::AbstractArray{X,1}) = reversi(reversi(xs)) == xs

# Properties do what we expect for some basic values 
@test property_rev_unit(1) == true 
@test property_rev_app([1,2], [3]) == true 
@test property_rev_app([1,2], []) == true 
@test property_rev_rev([1,2,3]) == true


function choose{X}(::Type{X}, range)
    return (size_limit,rng)->rand(rng,range)
end

arbitrary(s) = nothing 

arbitrary(::Type{Integer}) = choose(Integer, -1337:1337)


struct WeightedChoice
weight
choice
end

struct ChoiceRange
range
choice
end

function frequency(choices::Vector{WeightedChoice})
    ranges = Vector() 
    last_index = 0 
    for choice in choices
        append(!ranges, [ChoiceRange(last_index:last_index+choice.weight)])
        last_index = last_index+choice.weight
    end

    max_index = last_index
    
    # TODO: Binary search or something. This is just brute force. 
    
    function freq_choice(size, rng)
        index = choose(Integer, 0:max_index)(size,rng)
        for cand in ranges
            if index in cand.range
                return cand.choice
            end
        end
    end

    freq_choice
end

arbitrary(::Type{Bool}) = choose(Bool, [true, false])
function shrink(value::Bool)
    if value
        return [false]
    else
        return []
    end
end

function types_to_generate(amethod)
    sig_type = amethod.sig 
    tuple(sig_type.parameters[2:end]...)
end

test_one(s::Integer) = println("test one") 

our_only_test_one = first(methods(test_one))
@test (Integer,) == types_to_generate(our_only_test_one) 

function generate_args(to_gen)
    all_arbitraries = Vector()
    for t in to_gen
        println(t)
        append!(all_arbitraries, [arbitrary(t)])
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


struct PropertyFailedResult
method
fails::Int 
passes::Int
end

struct PropertyPassedResult
method
passes::Int
end 

struct ConditionUnmet end 


function quickCheck(property::Function)
    size = 13
    rand_seed = rand(RandomDevice(), 1:10000000)

    results = Vector() 
    for (i, method) in enumerate(methods(property))
        method_rng = MersenneTwister(rand_seed + i)
        method_res = quickCheck(size, method_rng, property, method)
        println(method_res)
        append!(results, [method_res])
    end

    results
end

function quickCheck(size, rand, func, property::Method)
    to_generate = types_to_generate(property)
    generator = generate_args(to_generate) 
    println(generator)
    
    passes = 0 
    fails = 0 
    for i in 1:100
        generated_args = generator(size,rand)
        result = func(generated_args...) 
        if result
            passes = passes + 1 
        else
            fails = fails + 1 
            if fails == 1 
                println("Failed on $(property)")
            end

            println("Counterexample: $(generated_args)")
        end
    end

    if fails > 0
        PropertyFailedResult(property, counterexamples) 
    else
        PropertyPassedResult(property, passes)
    end
end

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

arbitrary(::Type{IntegerLessThan{X}}) where X = (s,r)->IntegerLessThan{X}(choose(Integer, -1337:X)(s,r))

function shrink(value::IntegerLessThan{X}) where X
    return IntegerLessThan{X}(shrink(value.value))  
end

function some_property(x::IntegerLessThan{100})
    if x.value >= 100
        return false 
    else
        return true
    end
end

quickCheck(some_property)
