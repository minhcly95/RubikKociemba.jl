# We define a canon sequence (CS) to reduce the number of search repetitions.
# For example, U D and D U result in the same position, so we only need to search for 1 sequence.
# A canon sequence must satisfy:
# - No consecutive moves of the same face, e.g. U U2 should be reduced to U';
# - If 2 consecutive moves are of the opposite faces, then U, F, R come before D, B, L.
#   For example, D U is not canon, while U D is canon.

# Each entry is uneven, so Vector is better than Tuple
const NEXT_CS_FACE = (
    [Front, Right, Down, Back, Left],   # Up
    [Up, Right, Down, Back, Left],      # Front
    [Up, Front, Down, Back, Left],      # Right
    [Front, Right, Back, Left],         # Down
    [Up, Right, Down, Left],            # Back
    [Up, Front, Down, Back],            # Left
)

_all_faceturns(f::Face) = [FaceTurn(f, 1), FaceTurn(f, 2), FaceTurn(f, 3)]
_all_faceturns(fs::Vector{Face}) = vcat((_all_faceturns(f) for f in fs)...)
_all_next_cs_faceturns(f::Face) = _all_faceturns(NEXT_CS_FACE[f])

# The next FaceTurn in the canon seq only depends on the current face
const NEXT_CS_FACETURN = _all_next_cs_faceturns.(Face.(ALL_FACETURNS))

next_cs_faceturn(::Nothing) = ALL_FACETURNS
next_cs_faceturn(ft::FaceTurn) = @inbounds NEXT_CS_FACETURN[ft]

# Filter NEXT_CS_FACETURN to make NEXT_CS_HTURN
const NEXT_CS_HTURN = Tuple(HTurn.(filter(in(HTURN_TO_FACETURN), NEXT_CS_FACETURN[FaceTurn(ht)])) for ht in ALL_HTURNS)

next_cs_hturn(::Nothing) = ALL_HTURNS
next_cs_hturn(ht::HTurn) = @inbounds NEXT_CS_HTURN[ht]

