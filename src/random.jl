Base.rand(rng::AbstractRNG, ::Random.SamplerType{Perm4}) = rand(rng, ALL_PERM4)
Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerSlot}) = CornerSlot(rand(rng, 1:N_CORNERSLOTS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{EdgeSlot}) = EdgeSlot(rand(rng, 1:N_EDGESLOTS))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerOri}) = CornerOri(rand(rng, 1:N_CORNERORIS))
Base.rand(rng::AbstractRNG, ::Random.SamplerType{EdgeOri}) = EdgeOri(rand(rng, 1:N_EDGEORIS))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{HCoset}) = HCoset(rand(rng, CornerOri), rand(rng, EdgeOri), rand(rng, EdgeSlot))
