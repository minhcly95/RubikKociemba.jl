module RubikKociemba

using RubikCore
using RubikCore: N_CORNERS, N_EDGES
using Random
using StaticArrays

include("edgeori.jl")
include("cornerori.jl")
include("beltslot.jl")
include("hcoset.jl")
include("random.jl")

export CornerOri, EdgeOri, BeltSlot, HCoset

end
