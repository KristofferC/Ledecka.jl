module UnionTests 

using Ledecka
using Test 

@testset "Test reflection for unions" begin 
    @test [Integer] == union_types(Integer)
    @test [Integer] == union_types(Union{Integer})

    simple_union = Union{Integer, String} 
    @test [Integer, String] == union_types(simple_union)
    
    my_union = Union{Vector{String}, Integer, String}
    @test [Vector{String}, Integer, String] == union_types(my_union)
end

@testset "Basic saturation tests for unions" begin 
    result = arbitrary_saturation_law(Union{Integer, String}, 1337, 0.005)
    @test isa(result, LawPassed) 

    result2 = arbitrary_saturation_law(Union{Integer, String, Vector{String}}, 1337, 0.005)
    @test isa(result2, LawPassed)
end
end
