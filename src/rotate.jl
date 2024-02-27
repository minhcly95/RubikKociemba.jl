# FaceTurn rotation
(hs::HSymm)(ft::FaceTurn) = Symm(hs)(ft)

# HTurn rotation
const HSYMM_HTURN = Tuple(Tuple(HTurn(hs(FaceTurn(ht))) for ht in ALL_HTURNS) for hs in ALL_HSYMMS)
(hs::HSymm)(ht::HTurn) = @inbounds HSYMM_HTURN[hs][ht]

# HSymm acts on Cube by adjoining.
# In contrast, Symm acts on Cube by right translation.
(hs::HSymm)(c::Cube) = Cube(Symm(hs)(Move(c)))

# HCoset rotation
const HSYMM_CORNERORI = [CornerOri(hs(Cube(co))) for hs in ALL_HSYMMS, co in instances(CornerOri)]
(hs::HSymm)(co::CornerOri) = @inbounds HSYMM_CORNERORI[hs, co]

# Rotating BeltPerm adds a shift to EdgeOri, so we must rotate them simultaneously
const HSYMM_EDGEORI = [EdgeOri(hs(Cube(eo))) for hs in ALL_HSYMMS, eo in instances(EdgeOri)]
const HSYMM_BELTSLOT = [BeltSlot(hs(Cube(belt))) for hs in ALL_HSYMMS, belt in instances(BeltSlot)]
const HSYMM_BELTSLOT_ORISHIFT = [EdgeOri(hs(Cube(belt))) for hs in ALL_HSYMMS, belt in instances(BeltSlot)]

(hs::HSymm)(eo::EdgeOri, belt::BeltSlot) = @inbounds (HSYMM_EDGEORI[hs, eo] * HSYMM_BELTSLOT_ORISHIFT[hs, belt], HSYMM_BELTSLOT[hs, belt])

(hs::HSymm)(coset::HCoset) = HCoset(hs(coset.corner_ori), hs(coset.edge_ori, coset.belt_slot)...)

# HCube rotation
const HSYMM_CORNERPERM = [CornerPerm(hs(Cube(cp))) for hs in ALL_HSYMMS, cp in instances(CornerPerm)]
(hs::HSymm)(cp::CornerPerm) = @inbounds HSYMM_CORNERPERM[hs, cp]

const HSYMM_UPDOWNPERM = [UpDownPerm(hs(Cube(udp))) for hs in ALL_HSYMMS, udp in instances(UpDownPerm)]
(hs::HSymm)(udp::UpDownPerm) = @inbounds HSYMM_UPDOWNPERM[hs, udp]

const HSYMM_BELTPERM = [BeltPerm(hs(Cube(bp))) for hs in ALL_HSYMMS, bp in instances(BeltPerm)]
(hs::HSymm)(bp::BeltPerm) = @inbounds HSYMM_BELTPERM[hs, bp]

(hs::HSymm)(hc::HCube) = HCube(hs(hc.corner_perm), hs(hc.updown_perm), hs(hc.belt_perm))

