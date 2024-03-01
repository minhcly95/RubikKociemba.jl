# Compress the canon CornerPerm index
const CANON_CORNERPERM = Tuple(canonicalize.(instances(CornerPerm)))
const CORNERPERM_EXPAND = Tuple(unique(CANON_CORNERPERM))
const CORNERPERM_COMPRESS = Tuple(convert(UInt16, findfirst(==(canon), CORNERPERM_EXPAND)) for canon in CANON_CORNERPERM)
const N_CANON_CORNERPERM = length(CORNERPERM_EXPAND)

# Number of canon HCube of distance <= 15
const N_CANON_HCUBES_SUB15 = 100766620

# Lookup table for the distance of HCube.
# The maximum distance of an HCube is 18, but each entry is only 4 bit.
# Thus, we will check distance 0 explicitly (only the identity).
# For distance < 16, we will store it as distance - 1.
# For distance >= 16, we will store it as 0xf.
# We exclude the last component (BeltPerm) from the table to save space.
# For more information, see https://www.cube20.org/src/phase2prune.pdf.
struct Phase2Table
    table::NibbleArray{2}

    function Phase2Table(::UndefInitializer)
        new(NibbleArray(undef, N_CANON_CORNERPERM, N_UPDOWNPERMS))
    end
end

# Lookup function
function _phase2_index(hc::HCube)
    canon = canonicalize(hc)
    compress = @inbounds CORNERPERM_COMPRESS[canon.corner_perm]
    return Int(compress), Int(canon.updown_perm)
end

function Base.getindex(p2::Phase2Table, hc::HCube)
    (hc == HCube()) && return 0
    return convert(Int, @inbounds p2.table[_phase2_index(hc)...] + 1)
end

# Create table
function _create_phase2_table()
    p2 = Phase2Table(undef)

    # Fill the table with the maximum value.
    # We only need to write to the table if the value is not 0xf.
    fill!(p2.table, 0xf)

    # The distance of identity HCube = 0
    p2.table[_phase2_index(HCube())...] = 0

    # Breadth-first search
    num_hc = 1
    last_depth = [HCube()]
    curr_depth = HCube[]

    # No need to search for dist >= 16 since those entries are 0xf anyway
    for dist in 1:15
        for hc in last_depth
            # Only HTurns are valid for HCube
            for ht in ALL_HTURNS
                # Calculate the new HCube
                new_hc = hc * ht
                inds = _phase2_index(new_hc)
                # Set the entry if unvisited, and save the HCube for the next depth
                if @inbounds p2.table[inds...] == 0xf
                    @inbounds p2.table[inds...] = dist - 1
                    push!(curr_depth, new_hc)
                    num_hc += 1
                end
            end
        end
        println("At depth $dist: visited $num_hc / $N_CANON_HCUBES_SUB15")
        # Reset the arrays
        last_depth = curr_depth
        curr_depth = HCube[]
    end

    # Sanity check
    if num_hc != N_CANON_HCOSETS
        @warn "Mismatched number of canon HCube: $num_hc != $N_CANON_HCUBES_SUB15"
    end

    return p2
end

# Read and write
Base.write(io::IO, p2::Phase2Table) = write(io, p2.table)
Base.read!(io::IO, p2::Phase2Table) = (read!(io, p2.table); p2)

