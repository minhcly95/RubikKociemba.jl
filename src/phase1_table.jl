# Compress the canon CornerOri index
const CANON_CORNERORI = Tuple(canonicalize.(instances(CornerOri)))
const CORNERORI_EXPAND = Tuple(unique(CANON_CORNERORI))
const CORNERORI_COMPRESS = Tuple(convert(UInt8, findfirst(==(canon), CORNERORI_EXPAND)) for canon in CANON_CORNERORI)
const N_CANON_CORNERORI = length(CORNERORI_EXPAND)

# Number of total canon HCoset
const N_CANON_HCOSETS = 138639780

# Lookup table for the distance of HCoset
struct Phase1Table
    table::NibbleArray{3}

    function Phase1Table(::UndefInitializer)
        new(NibbleArray(undef, N_CANON_CORNERORI, N_EDGEORIS, N_BELTSLOTS))
    end
end

# Lookup function
function _phase1_index(coset::HCoset)
    canon = canonicalize(coset)
    compress = @inbounds CORNERORI_COMPRESS[canon.corner_ori]
    return Int(compress), Int(canon.edge_ori), Int(canon.belt_slot)
end

function Base.getindex(p1::Phase1Table, coset::HCoset)
    return convert(Int, @inbounds p1.table[_phase1_index(coset)...])
end

# Create table
function _create_phase1_table()
    p1 = Phase1Table(undef)

    # The maximum distance of an HCoset is 12, so 0xf represents the unvisited entries.
    fill!(p1.table, 0xf)

    # The distance of identity HCoset = 0
    p1.table[_phase1_index(HCoset())...] = 0

    # Breadth-first search
    num_cosets = 1
    last_depth = [HCoset()]
    curr_depth = HCoset[]

    for dist in 1:12
        for coset in last_depth
            for ft in ALL_FACETURNS
                # Calculate the new coset
                new_coset = ft * coset
                inds = _phase1_index(new_coset)
                # Set the entry if unvisited, and save the coset for the next depth
                if @inbounds p1.table[inds...] == 0xf
                    @inbounds p1.table[inds...] = dist
                    push!(curr_depth, new_coset)
                    num_cosets += 1
                end
            end
        end
        println("At depth $dist: visited $num_cosets / $N_CANON_HCOSETS")
        # Reset the arrays
        last_depth = curr_depth
        curr_depth = HCoset[]
    end

    # Sanity check
    if num_cosets != N_CANON_HCOSETS
        @warn "Mismatched number of canon HCoset: $num_cosets != $N_CANON_HCOSETS"
    end

    return p1
end

# Read and write
Base.write(io::IO, p1::Phase1Table) = write(io, p1.table)
Base.read!(io::IO, p1::Phase1Table) = (read!(io, p1.table); p1)

