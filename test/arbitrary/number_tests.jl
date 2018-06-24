module NumberTests 

using Test
using Ledecka

@testset "Number saturation" begin

result = arbitrary_saturation_law(Integer, 1337, 0.002)
@test isa(result, LawPassed) 

float_result = arbitrary_saturation_law(Float64, 1337, 0.05)
@test isa(float_result, LawPassed)

end

end
