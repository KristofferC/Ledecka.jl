module StrucTests
using Ledecka
using Test 


struct BroadTest 
    value::Dict{String, Vector{Integer}}
end
Ledecka.arbitrary(::Type{BroadTest}) = arbitrary_struct(BroadTest)

@testset "Struct saturation test" begin 
    result = arbitrary_saturation_law(BroadTest, 1337, 0.005)
    @test isa(result, LawPassed) 
end

end
