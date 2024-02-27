# Only the first 16 Symms are valid for the HCube.
# We wrap them in HSymm for context.
const N_HSYMMS = 16

# Struct
struct HSymm
    symm::Symm

    @inline function HSymm(symm::Symm)
        @boundscheck (1 <= Int(symm) <= N_HSYMMS) || throw(ArgumentError("cannot convert $symm to HSymm"))
        new(symm)
    end
end

# Identity
HSymm() = @inbounds HSymm(Symm())
Base.one(::Type{HSymm}) = HSymm()
Base.one(::HSymm) = HSymm()

# Convert to Symm
RubikCore.Symm(hs::HSymm) = hs.symm

# Convert from and to Int
Base.@propagate_inbounds HSymm(i::Integer) = HSymm(Symm(i))
Base.Int(hs::HSymm) = Int(hs.symm)
Base.convert(I::Type{<:Integer}, hs::HSymm) = convert(I, hs.symm)

# Get all instances of HSymm
Base.instances(::Type{HSymm}) = @inbounds HSymm.(1:N_HSYMMS)
const ALL_HSYMMS = Tuple(instances(HSymm))

# Static information
Base.copy(hs::HSymm) = hs
Base.typemin(::Type{HSymm}) = convert(UInt8, 1)
Base.typemax(::Type{HSymm}) = convert(UInt8, N_HSYMMS)

# Comparison
Base.isless(a::HSymm, b::HSymm) = a.symm < b.symm

# Get index shorthand
Base.@propagate_inbounds Base.getindex(a::Tuple, hs::HSymm) = getindex(a, convert(Int, hs))
Base.@propagate_inbounds Base.getindex(a::AbstractArray, Is::Union{HSymm,IntStruct}...) = getindex(a, (convert(Int, i) for i in Is)...)

# Parity
Base.iseven(hs::HSymm) = iseven(Symm(hs))
Base.isodd(hs::HSymm) = isodd(Symm(hs))

const EVEN_HSYMMS = Tuple(filter(iseven, ALL_HSYMMS))
const ODD_HSYMMS = Tuple(filter(isodd, ALL_HSYMMS))

# Get the image of the given face
(hs::HSymm)(f::Face) = Symm(hs)(f)

# Multiplication and inversion
Base.:*(a::HSymm, b::HSymm) = @inbounds HSymm(Symm(a) * Symm(b))
Base.inv(hs::HSymm) = @inbounds HSymm(inv(Symm(hs)))
Base.adjoint(hs::HSymm) = inv(hs)
Base.:^(hs::HSymm, p::Integer) = @inbounds HSymm(Symm(hs)^p)

# Print and parse
Base.print(io::IO, hs::HSymm) = print(io, hs.symm)
Base.show(io::IO, hs::HSymm) = print(io, "HSymm(\"$hs\")")

HSymm(str::AbstractString) = HSymm(Symm(str))
Base.parse(::Type{HSymm}, str::AbstractString) = HSymm(str)

