@testset "Rotation" begin
    @testset "Face rotation" begin
        for hs in ALL_HSYMMS
            # HSymm must map Up and Down to Up or Down
            @test hs(Up) in (Up, Down)
            @test hs(Down) in (Up, Down)
        end
    end

    @testset "HCoset rotation" begin
        for hs in rand(HSymm, 100)
            # Test with random Cube
            cube = rand(Cube)
            @test hs(HCoset(cube)) == HCoset(hs(cube))
            # Test with random HCoset
            coset = rand(HCoset)
            @test hs(coset) == HCoset(hs(Cube(coset)))
        end
    end

    @testset "HCube rotation" begin
        for hs in rand(HSymm, 100)
            hc = rand(HCube)
            @test hs(hc) == HCube(hs(Cube(hc)))
        end
    end

    @testset "FaceTurn seq * HCoset rotation" begin
        for hs in rand(HSymm, 100)
            coset = rand(HCoset)
            seq = rand(FaceTurn, 50)
            @test hs(seq * coset) == hs.(seq) * hs(coset)
        end
    end

    @testset "HCube * HTurn seq rotation" begin
        for hs in rand(HSymm, 100)
            hc = rand(HCube)
            seq = rand(HTurn, 50)
            @test hs(hc * seq) == hs(hc) * hs.(seq) 
        end
    end

    @testset "HCube mul rotation" begin
        for hs in rand(HSymm, 100)
            hc, hd = rand(HCube, 2)
            @test hs(hc * hd) == hs(hc) * hs(hd) 
        end
    end

    @testset "HCube inv rotation" begin
        for hs in rand(HSymm, 100)
            hc = rand(HCube)
            @test hs(hc') == hs(hc)'
        end
    end
end
