Base.rand(rng::AbstractRNG, ::Random.SamplerType{HTurn}) = rand(rng, ALL_HTURNS)
Base.rand(rng::AbstractRNG, ::Random.SamplerType{HSymm}) = rand(rng, ALL_HSYMMS)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerOri}) = CornerOri(rand(rng, 1:N_CORNERORIS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{EdgeOri}) = EdgeOri(rand(rng, 1:N_EDGEORIS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{BeltSlot}) = BeltSlot(rand(rng, 1:N_BELTSLOTS))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{HCoset}) = HCoset(rand(rng, CornerOri), rand(rng, EdgeOri), rand(rng, BeltSlot))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerPerm}) = CornerPerm(rand(rng, 1:N_CORNERPERMS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{UpDownPerm}) = UpDownPerm(rand(rng, 1:N_UPDOWNPERMS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{BeltPerm}) = BeltPerm(rand(rng, 1:N_BELTPERMS))

# Always generate a valid HCube
function Base.rand(rng::AbstractRNG, ::Random.SamplerType{HCube})
    cp = rand(rng, CornerPerm)
    udp = rand(rng, UpDownPerm)
    bp = rand(rng, BeltPerm)
    # Flip CornerPerm if parity is odd
    if isodd(cp) ⊻ isodd(udp) ⊻ isodd(bp)
        cp *= CornerPerm(lehmer_code(SPerm{8}(2,1)))    # Swap corner 1 and 2
    end
    return HCube(cp, udp, bp)
end
