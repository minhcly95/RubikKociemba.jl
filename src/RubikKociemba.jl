module RubikKociemba

using RubikCore
using RubikCore: N_CORNERS, N_EDGES
using Random
using StaticArrays

include("cornerori.jl")
include("edgeori.jl")
include("beltslot.jl")
include("hcoset.jl")
include("canon.jl")
include("random.jl")

export CornerOri, EdgeOri, BeltSlot, HCoset

end
