module NumberTests 

using Test
using Ledecka

@testset "Number saturation" begin

result = arbitrary_saturation_law(Integer, 1337, 0.002)
@test isa(result, LawPassed) 

float_result = arbitrary_saturation_law(Float64, 1337, 0.05)
@test isa(float_result, LawPassed)

test_value = just_an(arbitrary(Integer))
for i in 0:1337
    test_value = just_an(shrink(test_value))
end
@test test_value == 0 

end

end
