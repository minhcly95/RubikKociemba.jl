# HCoset
Base.rand(rng::AbstractRNG, ::Random.SamplerType{EdgeOri}) = EdgeOri(rand(rng, 1:N_EDGEORIS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerOri}) = CornerOri(rand(rng, 1:N_CORNERORIS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{BeltSlot}) = BeltSlot(rand(rng, 1:N_BELTSLOTS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{HCoset}) = HCoset(rand(rng, EdgeOri), rand(rng, CornerOri), rand(rng, BeltSlot))
