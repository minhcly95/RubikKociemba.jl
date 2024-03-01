@testset "HCube" begin
    @testset "Identity" begin
        @test HCube(Cube()) == HCube()
        for hc in rand(HCube, 10)
            @test hc * HCube() == hc
            @test HCube() * hc == hc
        end
    end

    @testset "Conversion" begin
        for _ in 1:100
            hc, hd = rand(HCube, 2)
            @test HCube(Cube(hc)) == hc
            @test HCube(Cube(hd)) == hd
            # The conversion is an isomorphism
            @test Cube(hc)' == Cube(hc')
            @test Cube(hc * hd) == Cube(hc) * Cube(hd)
        end
    end

    @testset "Random inverse" begin
        for hc in rand(HCube, 100)
            @test hc' * hc == HCube()
            @test hc * hc' == HCube()
        end
    end

    @testset "HTurn sequence" begin
        for hc in rand(HCube, 100)
            cube = Cube(hc)
            seq = rand(HTurn, 50)
            @test cube * seq == Cube(hc * seq)
        end
    end

    @testset "Sequence multiplication" begin
        for _ in 1:100
            seq1 = rand(HCube, 10)
            seq2 = rand(HCube, 10)
            seq3 = vcat(seq1, seq2)
            a, b, c = prod.((seq1, seq2, seq3))
            @test a * b == c
        end
    end

    @testset "Sequence inverse" begin
        for _ in 1:100
            seq = rand(HCube, 10)
            inv_seq = inv.(reverse(seq))
            a, b = prod.((seq, inv_seq))
            @test a == b'
        end
    end

    @testset "Validity" begin
        @test isvalid(HCube())
        for hc in rand(HCube, 100)
            @test isvalid(hc)
            @test isvalid(Cube(hc))
            @test isvalid(hc')
            @test isvalid(hc * rand(HTurn))
        end
    end
end
