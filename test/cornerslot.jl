@testset "CornerSlot" begin
    @testset "Conversion" begin
        for cube in rand(Cube, 100)
            up, down = CornerSlot.((cube,), (:up, :down))
            up_perm, down_perm = Perm4.((cube,), (up, down))
            @test opposite(up) == down

            cube2 = Cube(up, up_perm, down_perm)
            @test CornerSlot(cube2, :up) == up
            @test CornerSlot(cube2, :down) == down
            @test Perm4(cube2, up) == up_perm
            @test Perm4(cube2, down) == down_perm
        end
    end

    @testset "Sequence premul" begin
        for cube in rand(Cube, 100)
            up, down = CornerSlot.((cube,), (:up, :down))
            up_perm, down_perm = Perm4.((cube,), (up, down))

            seq = rand(FaceTurn, 50)
            cube2 = seq * cube
            up2, down2 = CornerSlot.((cube2,), (:up, :down))
            up_perm2, down_perm2 = Perm4.((cube2,), (up2, down2))

            @test (up2, up_perm2) == foldr(*, seq, init=(up, up_perm))
            @test (down2, down_perm2) == foldr(*, seq, init=(down, down_perm))
        end
    end
end
