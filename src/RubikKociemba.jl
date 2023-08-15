module RubikKociemba

using RubikCore
using RubikCore: N_CORNERS, N_EDGES
using Pkg.Artifacts, Random
using StaticArrays

include("macros.jl")

include("perm4.jl")
include("cornerslot.jl")
include("edgeslot.jl")
include("cornerori.jl")
include("edgeori.jl")

include("hcoset.jl")
include("permcube.jl")
include("canon.jl")

include("nibblearray.jl")
include("phase1.jl")

include("random.jl")

export Perm4, CornerSlot, EdgeSlot, CornerOri, EdgeOri, expand, permute
export HCoset, PermCube
export distance, solve

end
