module UnicodeTests

using Test 
using Ledecka

@testset "Basic unicode saturation tests" begin
    result = arbitrary_saturation_law(String, 1000, 0.005)
    @test isa(result, LawPassed)
end

end 
