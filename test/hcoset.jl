@testset "HCoset" begin
    @testset "Conversion" begin
        for coset in rand(HCoset, 100)
            @test HCoset(Cube(coset, rand(Cube))) == coset
        end
    end

    @testset "Sequence premul" begin
        for _ in 1:100
            cube = rand(Cube)
            seq = rand(FaceTurn, 50)
            @test HCoset(seq * cube) == seq * HCoset(cube)
        end
    end

    @testset "Canonicalization" begin
        for cube in rand(Cube, 100)
            coset = HCoset(cube)
            for symm in ALL_HSYMMS
                cube2 = Cube(rotate(Move(cube), symm))
                coset = min(coset, HCoset(cube2))
            end
            @test canonicalize(HCoset(cube)) == coset
        end
    end

    @testset "Count" begin
        count = 0
        for co in 1:N_CORNERORIS
            cornerori = @inbounds CornerOri(co)
            bits = @inbounds(_CORNERORI_CANONINFO[co]).min_bits
            if bits == 1
                count += N_EDGEORIS * N_BELTSLOTS
            elseif bits & 1 > 0
                for eo in 1:N_EDGEORIS
                    edgeori = @inbounds EdgeOri(eo)
                    for slot in 1:N_BELTSLOTS
                        beltslot = @inbounds BeltSlot(slot)
                        coset = HCoset(cornerori, edgeori, beltslot)
                        canon = canonicalize(coset)
                        (coset == canon) && (count += 1)
                    end
                end
            end
        end
        @test count == 138639780
    end
end
