const N_CANON_HCOSETS = 138639780

# Table creation
function _make_phase1_table()
    table = fill(Nibble(0xf), N_CANON_CORNERORIS, N_EDGEORIS, N_EDGESLOTS)
    table[1, 1, Int(HCoset().midslot)] = 0      # Identity
    seen = 1
    for d in 0:14
        for co_canon in 1:N_CANON_CORNERORIS
            co = @inbounds _CORNERORI_ALLCANON[co_canon]
            for eo_val in 1:N_EDGEORIS, ms_val in 1:N_EDGESLOTS
                eo = @inbounds EdgeOri(eo_val)
                ms = @inbounds EdgeSlot(ms_val)
                (table[co_canon, eo_val, ms_val] == d) || continue

                coset = HCoset(co, eo, ms)
                for ft in ALL_FACETURNS
                    coset2 = canonicalize(ft * coset)
                    co2, eo2, ms2 = Int(coset2.cornerori), Int(coset2.edgeori), Int(coset2.midslot)
                    co_canon2 = @inbounds _CORNERORI_CANONINFO[co2].index
                    if table[co_canon2, eo2, ms2] == 0xf
                        table[co_canon2, eo2, ms2] = d + 1
                        seen += 1
                    end
                end
            end
        end
        println("At level $(d + 1): seen $seen / $N_CANON_HCOSETS")
        (seen == N_CANON_HCOSETS) && break
    end
    return table
end

function _read_phase1_table(filename)
    table = NibbleArray(undef, N_CANON_CORNERORIS, N_EDGEORIS, N_EDGESLOTS)
    read!(filename, table)
    return table
end

function _read_phase1_table_from_artifact()
    artifact_path = joinpath(artifact"LookupTables", "phase1.dat")
    return _read_phase1_table(artifact_path)
end

const _PHASE1_TABLE = _read_phase1_table_from_artifact()

# Lookup routines
function distance(coset::HCoset)
    coset = canonicalize(coset)
    co_canon = @inbounds _CORNERORI_CANONINFO[Int(coset.cornerori)].index
    eo, ms = Int(coset.edgeori), Int(coset.midslot)
    return @inbounds Int(_PHASE1_TABLE[co_canon, eo, ms])
end

function solve(coset::HCoset)
    dist = distance(coset)
    seq = FaceTurn[]
    symm = Symm(1)
    for d in dist-1:-1:0
        for ft in ALL_FACETURNS
            coset2, symm2 = canonicalize(ft * coset, Symm)
            dist2 = distance(coset2)
            if dist2 == d
                coset = coset2
                push!(seq, rotate(ft, symm'))
                symm *= symm2
                break
            end
        end
    end
    return reverse!(seq)
end
