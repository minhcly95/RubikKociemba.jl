Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerOri}) = CornerOri(rand(rng, 1:N_CORNERORIS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{EdgeOri}) = EdgeOri(rand(rng, 1:N_EDGEORIS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{BeltSlot}) = BeltSlot(rand(rng, 1:N_BELTSLOTS))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{HCoset}) = HCoset(rand(CornerOri), rand(EdgeOri), rand(BeltSlot))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerPerm}) = CornerPerm(rand(rng, 1:N_CORNERPERMS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{UpDownPerm}) = UpDownPerm(rand(rng, 1:N_UPDOWNPERMS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{BeltPerm}) = BeltPerm(rand(rng, 1:N_BELTPERMS))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{HCube}) = HCube(rand(CornerPerm), rand(UpDownPerm), rand(BeltPerm))
