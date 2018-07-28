module UnicodeTests

using Test 
using Ledecka

@testset "Basic unicode saturation tests" begin
    result = arbitrary_saturation_law(String, 1000, 0.005)
    @test isa(result, LawPassed)

    result = arbitrary_saturation_law(AbstractString, 1000, 0.005)
    @test isa(result, LawPassed)

    result = arbitrary_saturation_law(Char, 1000, 0.005)
    @test isa(result, LawPassed)

    just_str = just_an(arbitrary(String))
    for i in 0:300
        just_str = just_an(shrink(just_str))
    end
    @test just_str == ""
end

end 
