module SequenceTests 

using Test
using Ledecka

@testset "Numeric Vector Saturation" begin
result = arbitrary_saturation_law(Vector{Integer}, 1337, 0.002)
@test isa(result, LawPassed)
end

@testset "Shrinking tests" begin
    some_val = just_an(arbitrary(Vector{Integer}))
    
    shrunk_result = some_val
    for i in 1:10
        println(shrunk_result)
        shrunk_result = just_an(shrink(shrunk_result)) 
    end
    @test length(shrunk_result) == 0
end


end
