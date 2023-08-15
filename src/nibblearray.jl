# Nibble
struct Nibble
    val::UInt8
    function Nibble(val::Integer)
        new(val & 0xf)
    end
end

Int(n::Nibble) = Int(n.val)

Base.show(io::IO, n::Nibble) = print(io, "0x", string(n.val, base=16))

Base.:(==)(a::Nibble, b::Integer) = a.val == b
Base.:(==)(a::Integer, b::Nibble) = a == b.val

Base.:+(a::Nibble, b::Integer) = a.val + b
Base.:+(a::Integer, b::Nibble) = a + b.val
Base.:+(a::Nibble, b::Nibble) = Nibble(a.val + b.val)

# NibbleArray
struct NibbleArray{N} <: AbstractArray{Nibble, N}
    data::Array{UInt8, N}
    odd::Bool
end

function NibbleArray(::UndefInitializer, dims::Union{Integer, AbstractUnitRange}...)
    dim1 = cld(dims[1], 2)
    return NibbleArray(Array{UInt8}(undef, dim1, Base.tail(dims)...), 2dim1 != dims[1])
end

function Base.fill(n::Nibble, dims::Union{Integer, AbstractUnitRange}...)
    byte = (n.val << 4) | n.val
    dim1 = cld(dims[1], 2)
    return NibbleArray(fill(byte, dim1, Base.tail(dims)...), 2dim1 != dims[1])
end

# Interface
function Base.size(array::NibbleArray)
    dims = size(array.data)
    return (array.odd ? 2dims[1] - 1 : 2dims[1], Base.tail(dims)...)
end

_nibblearray_index(I) = (fld1(I[1], 2), Base.tail(I)...)

Base.@propagate_inbounds function Base.getindex(array::NibbleArray, I::Int...)
    byte = getindex(array.data, _nibblearray_index(I)...)
    return Nibble(byte >> (4 * iseven(I[1])))
end

Base.@propagate_inbounds function Base.setindex!(array::NibbleArray, x::Integer, I::Int...)
    index = _nibblearray_index(I)
    byte = getindex(array.data, index...)
    shift = 4 * iseven(I[1])
    byte &= ~(0xf << shift)
    byte |= Nibble(x).val << shift
    setindex!(array.data, byte, index...)
    return array
end

# Read/write
Base.write(io::IO, array::NibbleArray) = write(io, array.data)

function Base.read!(io::IO, array::NibbleArray)
    read!(io, array.data)
    return array
end
