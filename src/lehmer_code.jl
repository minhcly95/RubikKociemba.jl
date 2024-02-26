# Designate a number for each 8-perm with Lehmer code
function lehmer_code(perm::AbstractPerm{N}) where {N}
    # We store the code as a mixed-radix number.
    # In particular, the first digit (most significant) has radix N, 2nd digit has radix N - 1, and so on.
    # The i-th digit counts the number of j > i just that perm[j] < perm[i]
    code = 0
    # The last digit is always 0, so we can skip the last loop
    for i in 1:N-1
        digit = 0
        for j in i+1:N
            if @inbounds perm[j] < perm[i]
                digit += 1
            end
        end
        code = (N + 1 - i) * code + digit
    end
    return code + 1
end

# Convert Lehmer code back to a permutation
# Note: not performance critical
function lehmer_perm(T::Type{<:AbstractPerm{N}}, code::Integer) where {N}
    code -= 1   # Correct for 1-indexing

    # Extract the digits in the code
    digits = Int[]
    for i in 1:N
        push!(digits, code % i)
        code = fld(code, i)
    end

    # Reconstruct the images
    images = Int[]
    S = collect(1:N)
    for d in reverse!(digits)
        @inbounds push!(images, S[d + 1])
        deleteat!(S, d + 1)
    end

    return T(images)
end

# We cache all the 4-perms and 8-perms based on their Lehmer's codes
const N_PERMS_4 = factorial(4)
const LEHMER_TO_PERM_4 = Tuple(lehmer_perm(SPerm{4,UInt8}, i) for i in 1:N_PERMS_4)

const N_PERMS_8 = factorial(8)
const LEHMER_TO_PERM_8 = Tuple(lehmer_perm(SPerm{8,UInt8}, i) for i in 1:N_PERMS_8)

