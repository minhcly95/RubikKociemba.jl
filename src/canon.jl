# Define an order
Base.isless(a::CornerOri, b::CornerOri) = Int(a) < Int(b)
Base.isless(a::EdgeOri, b::EdgeOri) = Int(a) < Int(b)
Base.isless(a::BeltSlot, b::BeltSlot) = Int(a) < Int(b)

Base.isless(a::HCoset, b::HCoset) =
    a.corner_ori < b.corner_ori || a.corner_ori == b.corner_ori &&
    (a.edge_ori < b.edge_ori || a.edge_ori == b.edge_ori && a.belt_slot < b.belt_slot)

# Symmatry of HCoset and HCube
const N_HSYMMS = 16
const ALL_HSYMMS = Tuple(Symm(s) for s in 1:N_HSYMMS)

function RubikCore.canonicalize(hcoset::HCoset)
    canoninfo = @inbounds _CORNERORI_CANONINFO[Int(hcoset.corner_ori)]
    co = canoninfo.canon_co
    eo = _rotate_edgeori(canoninfo.min_symm, hcoset.edge_ori, hcoset.belt_slot)
    slot = @inbounds _BELTSLOT_ROTATE[Int(hcoset.belt_slot)][Int(canoninfo.min_symm)]

    min_bits = canoninfo.min_bits >> (Int(canoninfo.min_symm) - 1)
    for s in Int(canoninfo.min_symm)+1:N_HSYMMS
        (min_bits == 0) && break
        min_bits >>= 1
        if min_bits & 1 > 0
            symm = @inbounds Symm(s)
            eo2 = _rotate_edgeori(symm, hcoset.edge_ori, hcoset.belt_slot)
            (eo2 > eo) && continue
            slot2 = @inbounds _BELTSLOT_ROTATE[Int(hcoset.belt_slot)][s]
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

# EdgeOri and BeltSlot rotation
const _EDGEORI_ROTATE = Tuple(Tuple(EdgeOri(Cube(rotate(Move(Cube(EdgeOri(eo))), symm))) for symm in ALL_HSYMMS) for eo in 1:N_EDGEORIS)

function _make_beltslot_rotate()
    beltslot_rotate = Matrix{BeltSlot}(undef, N_BELTSLOTS, N_HSYMMS)
    beltslot_oriflip = Vector{EdgeOri}(undef, N_BELTSLOTS)

    for i in 1:N_BELTSLOTS
        slot = BeltSlot(i)
        move = Move(Cube(slot))

        for symm in ALL_HSYMMS
            rot_cube = Cube(rotate(move, symm))
            slot2 = BeltSlot(rot_cube)
            beltslot_rotate[Int(slot), Int(symm)] = slot2
            if Int(symm) == 9
                beltslot_oriflip[Int(slot2)] = EdgeOri(rot_cube)
            end
        end
    end

    return Tuple(Tuple.(eachrow(beltslot_rotate))), Tuple(beltslot_oriflip)
end
const _BELTSLOT_ROTATE, _BELTSLOT_ORIFLIP = _make_beltslot_rotate()

@inline function _rotate_edgeori(symm::Symm, eo::EdgeOri, slot::BeltSlot)
    high_symm = Int(symm) >= 9
    eo_val = Int(eo) - 1
    eo_val ⊻= (Int(@inbounds(_BELTSLOT_ORIFLIP[Int(slot)])) - 1) * high_symm
    return @inbounds _EDGEORI_ROTATE[eo_val + 1][Int(symm)]
end
