# RubikKociemba

Kociemba's 2-phase algorithm to solve Rubik's cubes.

[![Build Status](https://github.com/minhcly95/RubikKociemba.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/minhcly95/RubikKociemba.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package implements the Kociemba's 2-phase algorithm to solve Rubik's cubes, ideally in less than 20 moves.
[RubikCore.jl](https://github.com/minhcly95/RubikCore.jl) is required.

## Tutorial

```julia
using RubikCore, RubikKociemba

# Create a random cube position (see RubikCore.jl for other options)
cube = rand(Cube)

# Solve it (default is to solve until we get a sequence of at most 20 moves)
# Warning: lowering target_length may result in very long solving time
seq = solve(cube; target_length = 20)

# Verify that the result actually solves the cube
solved_cube = cube * seq
@assert normalize(solved_cube) == Cube()
```

