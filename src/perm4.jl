const N_PERM4 = 24      # 24 = 4!

# Represent a permutation of 4 items (S_4 group)
RubikCore.@define_int_struct(Perm4, UInt8, N_PERM4)

Perm4() = @inbounds Perm4(1)

const ALL_PERM4 = Tuple(@inbounds Perm4(i) for i in 1:N_PERM4)

# Expand/compress to bit version
function _make_perm4_codec()
    compress = zeros(UInt8, 0xff)
    expand = zeros(UInt8, N_PERM4)
    current = 0
    for a in 1:4, b in 1:4
        (a == b) && continue
        for c in 1:4
            (a == c || b == c) && continue
            d = 10 - a - b - c
            comp = (current ⊻ ((current >> 1) & 1)) + 1
            exp = (1 << 2(b-1)) | (2 << 2(c-1)) | (3 << 2(d-1))
            compress[exp] = comp
            expand[comp] = exp
            current += 1
        end
    end
    @assert(current == N_PERM4)
    return Tuple(compress), Tuple(expand)
end
const _PERM4_COMPRESS, _PERM4_EXPAND = _make_perm4_codec()

Base.@propagate_inbounds function Perm4(a::Integer, b::Integer, c::Integer, d::Integer)
    @boundscheck (sort([a, b, c, d]) == 1:4) || throw(ArgumentError("invalid permutation: $((a, b, c, d))"))
    exp = ((d-1) << 6) | ((c-1) << 4) | ((b-1) << 2) | (a-1)
    return @inbounds Perm4(@inbounds _PERM4_COMPRESS[exp])
end

function expand(perm::Perm4)
    p = @inbounds _PERM4_EXPAND[Int(perm)]
    a = (p & 3) + 1
    b = ((p >> 2) & 3) + 1
    c = ((p >> 4) & 3) + 1
    d = ((p >> 6) & 3) + 1
    return (a, b, c, d)
end

# Operations
_mul_perm4_expanded(a, b) = (b[a[1]], b[a[2]], b[a[3]], b[a[4]])
function _make_perm4_mul()
    perm4_mul = Matrix{Perm4}(undef, N_PERM4, N_PERM4)
    for a in ALL_PERM4, b in ALL_PERM4
        perm4_mul[Int(a), Int(b)] = Perm4(_mul_perm4_expanded(expand(a), expand(b))...)
    end
    return Tuple(Tuple.(eachrow(perm4_mul)))
end
const _PERM4_MUL = _make_perm4_mul()
const _PERM4_INV = Tuple(Perm4(findfirst(==(Perm4()), _PERM4_MUL[Int(p)])) for p in ALL_PERM4)

Base.:*(a::Perm4, b::Perm4) = @inbounds _PERM4_MUL[Int(a)][Int(b)]
Base.inv(p::Perm4) = @inbounds _PERM4_INV[Int(p)]
Base.adjoint(p::Perm4) = inv(p)
Base.:^(p::Perm4, power::Integer) = Base.power_by_squaring(p, power)

# Print
Base.show(io::IO, p::Perm4) = print(io, "Perm$(expand(p))")
