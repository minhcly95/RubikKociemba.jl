using RubikKociemba
using RubikKociemba: N_CORNERORIS, N_EDGEORIS, N_EDGESLOTS, ALL_HSYMMS, _CORNERORI_CANONINFO, N_CANON_HCOSETS
using Test
using RubikCore

@testset "RubikKociemba.jl" begin
    include("cornerslot.jl")
    include("edgeslot.jl")
    include("hcoset.jl")
    include("permcube.jl")
    include("phase1.jl")
end
