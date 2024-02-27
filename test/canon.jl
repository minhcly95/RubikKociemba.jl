@testset "Canonicalization" begin
    @testset "HCoset" begin
        for coset in rand(HCoset, 100)
            canon, hs = canonicalize_hsymm(coset)
            target = minimum(hs(coset) for hs in ALL_HSYMMS)
            # Correctness
            @test canon == target
            @test canon == hs(coset)
            # Invariant
            @test canonicalize(rand(ALL_HSYMMS)(coset)) == canon
            @test canonicalize(canon) == canon
        end
    end

    @testset "HCube" begin
        for hc in rand(HCube, 100)
            canon, hs = canonicalize_hsymm(hc)
            target = minimum(hs(hc) for hs in ALL_HSYMMS)
            # Correctness
            @test canon == target
            @test canon == hs(hc)
            # Invariant
            @test canonicalize(rand(ALL_HSYMMS)(hc)) == canon
            @test canonicalize(canon) == canon
        end
    end

    @testset "Canon CornerOri count" begin
        canons = canonicalize.(instances(CornerOri))
        @test length(unique!(canons)) == 168
    end

    @testset "Canon CornerPerm count" begin
        canons = canonicalize.(instances(CornerPerm))
        @test length(unique!(canons)) == 2768
    end
end
