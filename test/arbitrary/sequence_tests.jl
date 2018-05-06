module SequenceTests 

using Test
using Ledecka

@testset "Numeric Vector Saturation" begin
result = arbitrary_saturation_law(Vector{Integer}, 1337, 0.002)
@test isa(result, LawPassed)
end

end
