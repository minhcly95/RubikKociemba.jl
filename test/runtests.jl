using RubikKociemba
using RubikCore, RubikCore.Literals
using Test

import RubikKociemba: ALL_HTURNS, ALL_HSYMMS

@testset "RubikKociemba.jl" begin
    include("hcoset.jl")
    include("hcube.jl")
    include("rotate.jl")
end
