module TupleTests

using Ledecka
using Test

@testset "Tuple tests" begin

tuple_result = arbitrary_saturation_law(NTuple{4, Int64}, 1000, 0.05)
@test isa(tuple_result, LawPassed)


tuple_result = arbitrary_saturation_law(NTuple{4, NTuple{5,Int64}}, 1000, 0.05)
@test isa(tuple_result, LawPassed)


tuple_result = arbitrary_saturation_law(NTuple{4, Int64}, 1000, 0.05)
@test isa(tuple_result, LawPassed)


tuple_result = arbitrary_saturation_law(Tuple{Int64, Bool, UInt8}, 1000, 0.05)
@test isa(tuple_result, LawPassed)

end




end
