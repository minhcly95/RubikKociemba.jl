# Define an order
function Base.isless(a::HCoset, b::HCoset)
    return (a.corner_ori < b.corner_ori) ||
           (a.corner_ori == b.corner_ori &&
            (a.edge_ori < b.edge_ori || a.edge_ori == b.edge_ori && a.belt_slot <= b.belt_slot))
end

function Base.isless(a::HCube, b::HCube)
    return (a.corner_perm < b.corner_perm) ||
           (a.corner_perm == b.corner_perm &&
            (a.updown_perm < b.updown_perm || a.updown_perm == b.updown_perm && a.belt_perm <= b.belt_perm))
end

# Find the minimum coset::HCoset across all symmetries hs(coset) for hs in ALL_HSYMMS
RubikCore.canonicalize(coset::HCoset) = canonicalize_hsymm(coset)[1]

function canonicalize_hsymm(coset::HCoset)
    co = coset.corner_ori
    eo = coset.edge_ori
    belt = coset.belt_slot
    min_hs = HSymm()

    for hs in ALL_HSYMMS[2:end]
        # Rotate each component separately and stop whenever new component is larger
        # This is a bit faster than writing minimum(hs(coset) for hs in ALL_HSYMMS)
        new_co = hs(coset.corner_ori)
        if new_co < co
            # New CornerOri is better
            min_hs = hs
            co = new_co
            eo = hs(coset.edge_ori, coset.belt_slot)
            belt = hs(coset.belt_slot)
        elseif new_co == co
            new_eo = hs(coset.edge_ori, coset.belt_slot)
            if new_eo < eo
                # New EdgeOri is better
                min_hs = hs
                eo = new_eo
                belt = hs(coset.belt_slot)
            elseif new_eo == eo
                new_belt = hs(coset.belt_slot)
                if new_belt < belt
                    # New BeltSlot is better
                    min_hs = hs
                    belt = new_belt
                end
            end
        end
    end

    return HCoset(co, eo, belt), min_hs
end

# Find the minimum hc::HCube across all symmetries hs(hc) for hs in ALL_HSYMMS
RubikCore.canonicalize(hc::HCube) = canonicalize_hsymm(hc)[1]

function canonicalize_hsymm(hc::HCube)
    cp = hc.corner_perm
    udp = hc.updown_perm
    bp = hc.belt_perm
    min_hs = HSymm()

    for hs in ALL_HSYMMS[2:end]
        # Rotate each component separately and stop whenever new component is larger
        # This is a bit faster than writing minimum(hs(hc) for hs in ALL_HSYMMS)
        new_cp = hs(hc.corner_perm)
        if new_cp < cp
            # New CornerPerm is better
            min_hs = hs
            cp = new_cp
            udp = hs(hc.updown_perm)
            bp = hs(hc.belt_perm)
        elseif new_cp == cp
            new_udp = hs(hc.updown_perm)
            if new_udp < udp
                # New UpDownPerm is better
                min_hs = hs
                udp = new_udp
                bp = hs(hc.belt_perm)
            elseif new_udp == udp
                new_bp = hs(hc.belt_perm)
                if new_bp < bp
                    # New BeltPerm is better
                    min_hs = hs
                    bp = new_bp
                end
            end
        end
    end

    return HCube(cp, udp, bp), min_hs
end

# For utility, we also provide canonicalization for CornerOri and CornerPerm
RubikCore.canonicalize(co::CornerOri) = minimum(hs(co) for hs in ALL_HSYMMS)
RubikCore.canonicalize(cp::CornerPerm) = minimum(hs(cp) for hs in ALL_HSYMMS)

