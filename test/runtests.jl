using Test
using Pkg
using QuantumToolbox
using QuantumToolbox: position, momentum
using Random
using SciMLOperators

const GROUP = get(ENV, "GROUP", "All")

const testdir = dirname(@__FILE__)

# Put core tests in alphabetical order
core_tests = [
    "correlations_and_spectrum.jl",
    "dynamical_fock_dimension_mesolve.jl",
    "dynamical-shifted-fock.jl",
    "eigenvalues_and_operators.jl",
    "entanglement.jl",
    "generalized_master_equation.jl",
    "low_rank_dynamics.jl",
    "negativity_and_partial_transpose.jl",
    "permutation.jl",
    "progress_bar.jl",
    "quantum_objects.jl",
    "quantum_objects_evo.jl",
    "states_and_operators.jl",
    "steady_state.jl",
    "time_evolution.jl",
    "utilities.jl",
    "wigner.jl",
]

if (GROUP == "All") || (GROUP == "Code-Quality")
    Pkg.add(["Aqua", "JET"])
    include(joinpath(testdir, "core-test", "code_quality.jl"))
end

if (GROUP == "All") || (GROUP == "Core")
    QuantumToolbox.about()

    for test in core_tests
        include(joinpath(testdir, "core-test", test))
    end
end

if (GROUP == "CUDA_Ext")# || (GROUP == "All")
    Pkg.add("CUDA")
    include(joinpath(testdir, "ext-test", "cuda_ext.jl"))
end
