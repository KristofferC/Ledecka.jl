using Test 

@testset "Ledecka.jl tests" begin

@testset "Core Tests" begin 
include("CoreTests.jl")
end

@testset "Default Arbitrary Implementation Tests" begin
include("arbitrary/number_tests.jl")
include("arbitrary/sequence_tests.jl")
include("arbitrary/unicode_tests.jl")
include("arbitrary/dictionary_tests.jl") 
include("arbitrary/struct_tests.jl") 
include("arbitrary/union_tests.jl")
include("arbitrary/tuple_tests.jl")
end

@testset "Example Tests" begin
include("PaperExample.jl")
include("CheckersExample.jl")
end
end

