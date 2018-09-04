# Ledecka.jl

> Give your code a quickCheck before it gets off the         chairlift. ⛷️ 🥇🥇

![A tram and a skier getting off of it to ride towards the name of the project](/docs/ledecka_logo.png)

Ledecka.jl is a property-based testing library in the style of Haskell's quickCheck. Ledecka takes properties of a program,
represented as methods with typed parameters, and tests that they are true for many randomized inputs.

## Install 

Ledecka supports Julia versions 0.7 and higher. Ledecka is not
currently registered in the Uncurated Julia package repository,
and thus needs to be installed directly. 

Ledecka can be installed using Julia's built in package manager, in one of two ways. 

Using the package manager repl: 
1. Start a julia repl
2. At the prompt, press the ] key (The prompt should change to `pkg>`)
3. Type the following and press enter: 
``` 
add https://github.com/polytomous/Ledecka.jl#Kappa
```

Using just the Julia repl: 
1. Start a julia repl
2. In the prompt, enter `using Pkg3`
3. Type the following and press enter: 
``` 
pkg"add https://github.com/polytomous/Ledecka.jl#Kappa"
```

## Usage 

Ledecka properties should be represented as methods with typed 
parameters. For example, to test reversing an arbitrary list with 
the standard library's `reverse` function, we could write this
property, which states that a list reversed twice should equal the original list.  

``` 
function reverse_property(x::Vector{Integer})
    reverse(reverse(x)) == x
end
```

To test that the property is true for many random example vectors of integers, we call Ledecka's `quickCheck` method. 

``` 
using Ledecka
result = quickCheck(reverseProperty)
@test isa(result, TestSuccess)
```

The value that `quickCheck` returns encodes the result of that property. 
All of the methods of a property function are tested, so a property is considered to pass if and only if all methods ran successfully. 
Property methods are classified as passing if the result passed in to `Ledecka.property_pass` evaluates to `true`. 
Additional `property_pass` methods can be allowed to support more types of return values from properties.  
When the test fails, this return value allows you to
access the counter examples discovered by Ledecka.

Ledecka can only generate types which have an appropriate `Ledecka.arbitrary` implementation. To see which types are supported at any time, use `methods(arbitrary)`. Ledecka comes with many useful arbitrary implementations built in, and it is possible to add more as needed.

## Supporting new types 

Ledecka represents supported types as implementations of `Ledecka.arbitrary`. Arbitrary implementations should return a callable which takes two parameters, a size and rng parameters, and when called produces an instance of the arbitrary type. 

An implementation of arbitrary for Integer values could look like this: 

```
function arbitrary(::Type{Integer})
    function arb(size, rng)
        return rand(rng, 1:1337)
    end
    
    arb
end
```

The `size` parameter currently isn't used, but will be used in the future to constrain the output of arbitrary instances and for use in shrinking values to reduce test cases. 
`rng` is a source of randomness, typically assumed to be a psuedorandom number generator like `MersenneTwister` or a hardware random nubmer generator like `RandomDevice`.

For a given `arbitrary(::Type{T}) where T`, it is important that the inner callable always return values of type `T`, except in the cases where the arbitrary experienced an error. This makes it so that properties are appropriately called based on their generated parameters. 

## License 

[BSD3](LICENSE.md)

## Send help! 

I would love your contributions, or would love to pair with you to find contributions that you could feel good about making. The easiest way for you to contribute is to use the library and write `arbitrary` implementations. 
