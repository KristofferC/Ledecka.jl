module Ledecka

include("arbitrary/arbitrary.jl")
include("quickcheck.jl")
include("arbitrary/numbers.jl")
include("arbitrary/sequences.jl")
include("arbitrary/unicode.jl")
include("arbitrary/dictionaries.jl")
include("arbitrary/structs.jl") 
include("arbitrary/unions.jl")
include("arbitrary/tuples.jl")

end # module
