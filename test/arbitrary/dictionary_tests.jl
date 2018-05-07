module DictionaryTests 
using Ledecka 
using Test

@testset "Basic dictionary saturation tests" begin 
    result = arbitrary_saturation_law(Dict{Integer, Integer}, 1337, 0.005)
    @test isa(result, LawPassed)
end
end

