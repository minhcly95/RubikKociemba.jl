# Nibble represents a 4-bit number.
# Although it is stored as an UInt8, it provides context to NibbleArray.
struct Nibble <: Integer
    val::UInt8
    Nibble(val::Integer) = new(val & 0xf)
end

# Conversion and Promotion
Base.convert(::Type{Nibble}, x::Integer) = Nibble(x)
Base.convert(::Type{Nibble}, x::Nibble) = x

Base.convert(T::Type{<:Integer}, x::Nibble) = convert(T, x.val)
(T::Type{<:Integer})(x::Nibble) = convert(T, x)

Base.promote_rule(::Type{Nibble}, T::Type{<:Integer}) = promote_type(UInt8, T)

# Arithmetic
Base.:+(a::Nibble, b::Nibble) = Nibble(a.val + b.val)
Base.:*(a::Nibble, b::Nibble) = Nibble(a.val * b.val)

# Print
Base.show(io::IO, x::Nibble) = print(io, "0x", string(x.val, base=16))

# Array of Nibble, stores 2 entries per byte.
struct NibbleArray{N} <: AbstractArray{Nibble,N}
    inner::Array{UInt8,N}
    dims::NTuple{N,Int}
    function NibbleArray(::UndefInitializer, dims::Integer...)
        new{length(dims)}(Array{UInt8}(undef, fld1(first(dims), 2), Base.tail(dims)...), dims)
    end
end

# Array interface
Base.size(A::NibbleArray) = A.dims
Base.sizeof(A::NibbleArray) = sizeof(A.inner)

@inline function Base.getindex(A::NibbleArray, I::Int...)
    @boundscheck checkbounds(Bool, A, I...) || throw(BoundsError(A, I))
    first_ind = first(I)
    inner_ind = (first_ind - 1) >> 1 + 1
    cell = @inbounds A.inner[inner_ind, Base.tail(I)...]
    return isodd(first_ind) ? Nibble(cell) : Nibble(cell >> 4)
end

@inline function Base.setindex!(A::NibbleArray, v::Integer, I::Int...)
    @boundscheck checkbounds(Bool, A, I...) || throw(BoundsError(A, I))
    first_ind = first(I)
    inner_ind = (first_ind - 1) >> 1 + 1
    cell = @inbounds A.inner[inner_ind, Base.tail(I)...]
    if isodd(first_ind)
        cell &= 0xf0
        cell |= convert(Nibble, v).val
    else
        cell &= 0x0f
        cell |= convert(Nibble, v).val << 4
    end
    @inbounds A.inner[inner_ind, Base.tail(I)...] = cell
    return v
end

# Read and write
Base.write(io::IO, A::NibbleArray) = write(io, A.inner)
Base.read!(io::IO, A::NibbleArray) = (read!(io, A.inner); A)

