# HTurns are FaceTurns that are valid for the H group
const HTURN_TO_FACETURN = (
    (FaceTurn(Up, t) for t in 1:3)...,
    (FaceTurn(Down, t) for t in 1:3)...,
    (FaceTurn(f, 2) for f in (Front, Right, Back, Left))...
)
const N_HTURNS = length(HTURN_TO_FACETURN)

@int_struct struct HTurn <: AbstractMove
    N_HTURNS::UInt8
end

# Get all instances of HTurn
Base.instances(::Type{HTurn}) = @inbounds HTurn.(1:N_HTURNS)
const ALL_HTURNS = Tuple(instances(HTurn))

# Get index shorthand
Base.@propagate_inbounds Base.getindex(a::Tuple, ht::HTurn) = getindex(a, convert(Int, ht))

# Convert from and to FaceTurn
RubikCore.FaceTurn(ht::HTurn) = @inbounds HTURN_TO_FACETURN[ht]

const FACETURN_TO_HTURN = Tuple(something(findfirst(==(ft), HTURN_TO_FACETURN), 0) for ft in instances(FaceTurn))
@inline function HTurn(ft::FaceTurn)
    ind = @inbounds FACETURN_TO_HTURN[ft]
    @boundscheck ind == 0 && throw(ArgumentError("cannot convert $ft to HTurn"))
    return @inbounds HTurn(ind)
end

# Conversion from and to Face and twist
RubikCore.Face(ht::HTurn) = Face(FaceTurn(ht))
twist(ht::HTurn) = twist(FaceTurn(ht))

Base.@propagate_inbounds HTurn(face::Face, twist::Integer) = HTurn(FaceTurn(face, twist))

# Convert from and to Move
RubikCore.Move(ht::HTurn) = Move(FaceTurn(ht))
HTurn(m::Move) = HTurn(FaceTurn(m))

# Specialized operations
Base.inv(ht::HTurn) = @inbounds HTurn(inv(FaceTurn(ht)))
Base.:^(ht::HTurn, p::Integer) = @inbounds HTurn(FaceTurn(ht)^p)

# Print
Base.print(io::IO, ht::HTurn) = print(io, Move(ht))
Base.show(io::IO, ht::HTurn) = print(io, "HTurn($(Move(ht)))")

