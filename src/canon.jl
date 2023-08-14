# Define an order
Base.isless(a::CornerOri, b::CornerOri) = Int(a) < Int(b)
Base.isless(a::EdgeOri, b::EdgeOri) = Int(a) < Int(b)
Base.isless(a::EdgeSlot, b::EdgeSlot) = Int(a) < Int(b)

Base.isless(a::HCoset, b::HCoset) =
    a.cornerori < b.cornerori || a.cornerori == b.cornerori &&
    (a.edgeori < b.edgeori || a.edgeori == b.edgeori && a.midslot < b.midslot)

# Symmatry of HCoset and HCube
const N_HSYMMS = 16
const ALL_HSYMMS = Tuple(Symm(s) for s in 1:N_HSYMMS)

function RubikCore.canonicalize(hcoset::HCoset)
    canoninfo = @inbounds _CORNERORI_CANONINFO[Int(hcoset.cornerori)]
    co = canoninfo.canon_co
    eo = _rotate_edgeori(canoninfo.min_symm, hcoset.edgeori, hcoset.midslot)
    slot = @inbounds _MIDSLOT_ROTATE[Int(hcoset.midslot)][Int(canoninfo.min_symm)]

    min_bits = canoninfo.min_bits >> (Int(canoninfo.min_symm) - 1)
    for s in Int(canoninfo.min_symm)+1:N_HSYMMS
        (min_bits == 0) && break
        min_bits >>= 1
        if min_bits & 1 > 0
            symm = @inbounds Symm(s)
            eo2 = _rotate_edgeori(symm, hcoset.edgeori, hcoset.midslot)
            (eo2 > eo) && continue
            slot2 = @inbounds _MIDSLOT_ROTATE[Int(hcoset.midslot)][s]
            if eo2 < eo  || slot2 < slot
                eo = eo2
                slot = slot2
            end
        end
    end

    return HCoset(co, eo, slot)
end

# CornerOri canonicalization
struct CornerOriCanonInfo
    canon_co::CornerOri
    min_symm::Symm
    min_bits::UInt16
end

const N_CANON_CORNERORIS = 168

function _make_cornerori_canoninfo()
    canoninfo = CornerOriCanonInfo[]
    for i in 1:N_CORNERORIS
        co = CornerOri(i)
        move = Move(Cube(co))
        canon_co = i
        min_symm = Symm()
        min_bits = 1
        for s in 2:16
            symm = @inbounds Symm(s)
            co2 = CornerOri(Cube(rotate(move, symm)))
            if Int(co2) < canon_co
                canon_co = Int(co2)
                min_symm = symm
                min_bits = 1 << (s-1)
            elseif Int(co2) == canon_co
                min_bits |= 1 << (s-1)
            end
        end
        push!(canoninfo, CornerOriCanonInfo(CornerOri(canon_co), min_symm, min_bits))
    end
    @assert length(unique!(map(info -> info.canon_co, canoninfo))) == N_CANON_CORNERORIS
    return Tuple(canoninfo)
end
const _CORNERORI_CANONINFO = _make_cornerori_canoninfo()

# EdgeOri and EdgeSlot rotation
const _EDGEORI_ROTATE = Tuple(Tuple(EdgeOri(Cube(rotate(Move(Cube(EdgeOri(eo))), symm))) for symm in ALL_HSYMMS) for eo in 1:N_EDGEORIS)

function _make_midslot_rotate()
    midslot_rotate = Matrix{EdgeSlot}(undef, N_EDGESLOTS, N_HSYMMS)
    midslot_oriflip = Vector{EdgeOri}(undef, N_EDGESLOTS)

    for i in 1:N_EDGESLOTS
        mid = EdgeSlot(i)
        up, down = opposite(mid)
        move = Move(Cube(up, mid, down, Perm4(), Perm4(), Perm4()))

        for symm in ALL_HSYMMS
            rot_cube = Cube(rotate(move, symm))
            mid2 = EdgeSlot(rot_cube, :mid)
            midslot_rotate[Int(mid), Int(symm)] = mid2
            if Int(symm) == 9
                midslot_oriflip[Int(mid2)] = EdgeOri(rot_cube)
            end
        end
    end

    return Tuple(Tuple.(eachrow(midslot_rotate))), Tuple(midslot_oriflip)
end
const _MIDSLOT_ROTATE, _MIDSLOT_ORIFLIP = _make_midslot_rotate()

@inline function _rotate_edgeori(symm::Symm, eo::EdgeOri, slot::EdgeSlot)
    high_symm = Int(symm) >= 9
    eo_val = Int(eo) - 1
    eo_val ⊻= @inbounds (Int(_MIDSLOT_ORIFLIP[Int(slot)]) - 1) * high_symm
    return @inbounds _EDGEORI_ROTATE[eo_val + 1][Int(symm)]
end
