@testset "EdgeSlot" begin
    @testset "Conversion" begin
        for cube in rand(Cube, 100)
            up, mid, down = EdgeSlot.((cube,), (:up, :mid, :down))
            up_perm, mid_perm, down_perm = Perm4.((cube,), (up, mid, down))
            cube2 = Cube(up, mid, down, up_perm, mid_perm, down_perm)
            @test EdgeSlot(cube2, :up) == up
            @test EdgeSlot(cube2, :mid) == mid
            @test EdgeSlot(cube2, :down) == down
            @test Perm4(cube2, up) == up_perm
            @test Perm4(cube2, mid) == mid_perm
            @test Perm4(cube2, down) == down_perm
        end
    end

    @testset "Opposite" begin
        for a in rand(EdgeSlot, 100)
            b, c = opposite(a)
            @test sort!(collect(Iterators.flatten(expand.([a, b, c])))) == 1:12
        end
    end

    @testset "Sequence premul" begin
        for cube in rand(Cube, 100)
            up, mid, down = EdgeSlot.((cube,), (:up, :mid, :down))
            up_perm, mid_perm, down_perm = Perm4.((cube,), (up, mid, down))

            seq = rand(FaceTurn, 50)
            cube2 = seq * cube
            up2, mid2, down2 = EdgeSlot.((cube2,), (:up, :mid, :down))
            up_perm2, mid_perm2, down_perm2 = Perm4.((cube2,), (up2, mid2, down2))

            @test (up2, up_perm2) == foldr(*, seq, init=(up, up_perm))
            @test (mid2, mid_perm2) == foldr(*, seq, init=(mid, mid_perm))
            @test (down2, down_perm2) == foldr(*, seq, init=(down, down_perm))
        end
    end
end
