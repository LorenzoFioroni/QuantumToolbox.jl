export steadystate, steadystate_floquet
export SteadyStateSolver, SteadyStateDirectSolver

abstract type SteadyStateSolver end

struct SteadyStateDirectSolver <: SteadyStateSolver end

function steadystate(
    L::QuantumObject{<:AbstractArray{T},SuperOperatorQuantumObject};
    solver::SteadyStateSolver = SteadyStateDirectSolver(),
) where {T}
    return _steadystate(L, solver)
end

function steadystate(
    H::QuantumObject{<:AbstractArray{T},OpType},
    c_ops::Vector,
    solver::SteadyStateSolver = SteadyStateDirectSolver(),
) where {T,OpType<:Union{OperatorQuantumObject,SuperOperatorQuantumObject}}
    L = liouvillian(H, c_ops)

    return steadystate(L, solver = solver)
end

function _steadystate(
    L::QuantumObject{<:AbstractArray{T},SuperOperatorQuantumObject},
    solver::SteadyStateDirectSolver,
) where {T}
    L_tmp = L.data
    N = prod(L.dims)
    weight = norm(L_tmp, 1) / length(L_tmp)

    v0 = _get_dense_similar(L_tmp, N^2)
    fill!(v0, 0)
    allowed_setindex!(v0, weight, 1) # Because scalar indexing is not allowed on GPU arrays

    idx_range = collect(1:N)
    rows = _get_dense_similar(L_tmp, N)
    cols = _get_dense_similar(L_tmp, N)
    datas = _get_dense_similar(L_tmp, N)
    fill!(rows, 1)
    copyto!(cols, N .* (idx_range .- 1) .+ idx_range)
    fill!(datas, weight)
    Tn = sparse(rows, cols, datas, N^2, N^2)
    L_tmp = L_tmp + Tn

    ρss_vec = L_tmp \ v0 # This is still not supported on GPU, yet
    ρss = reshape(ρss_vec, N, N)
    ρss = (ρss + ρss') / 2 # Hermitianize
    return QuantumObject(ρss, Operator, L.dims)
end

@doc raw"""
    steadystate_floquet(H_0::QuantumObject,
        c_ops::Vector, H_p::QuantumObject,
        H_m::QuantumObject,
        ω::Real; n_max::Int=4,
        tol::Real=1e-15,
        ss_solver::SteadyStateSolver=SteadyStateDirectSolver())

Calculates the steady state of a periodically driven system.
Here `H_0` is the Hamiltonian or the Liouvillian of the undriven system.
Considering a monochromatic drive at frequency ``\\omega``, we divide it into two parts,
`H_p` and `H_m`, where `H_p` oscillates
as ``e^{i \\omega t}`` and `H_m` oscillates as ``e^{-i \\omega t}``.
`n_max` is the number of iterations used to obtain the effective Liouvillian,
and `ss_solver` is the solver used to solve the steady state.
"""
function steadystate_floquet(
    H_0::QuantumObject{<:AbstractArray{T1},OpType1},
    c_ops::AbstractVector,
    H_p::QuantumObject{<:AbstractArray{T2},OpType2},
    H_m::QuantumObject{<:AbstractArray{T3},OpType3},
    ω::Real;
    n_max::Int = 4,
    tol::Real = 1e-15,
    ss_solver::SteadyStateSolver = SteadyStateDirectSolver(),
) where {
    T1,
    T2,
    T3,
    OpType1<:Union{OperatorQuantumObject,SuperOperatorQuantumObject},
    OpType2<:Union{OperatorQuantumObject,SuperOperatorQuantumObject},
    OpType3<:Union{OperatorQuantumObject,SuperOperatorQuantumObject},
}
    L_0 = liouvillian(H_0, c_ops)
    L_p = liouvillian(H_p)
    L_m = liouvillian(H_m)

    return steadystate(liouvillian_floquet(L_0, L_p, L_m, ω, n_max = n_max, tol = tol), solver = ss_solver)
end

function steadystate_floquet(
    H_0::QuantumObject{<:AbstractArray{T1},OpType1},
    H_p::QuantumObject{<:AbstractArray{T2},OpType2},
    H_m::QuantumObject{<:AbstractArray{T3},OpType3},
    ω::Real;
    n_max::Int = 4,
    tol::Real = 1e-15,
    ss_solver::SteadyStateSolver = SteadyStateDirectSolver(),
) where {
    T1,
    T2,
    T3,
    OpType1<:Union{OperatorQuantumObject,SuperOperatorQuantumObject},
    OpType2<:Union{OperatorQuantumObject,SuperOperatorQuantumObject},
    OpType3<:Union{OperatorQuantumObject,SuperOperatorQuantumObject},
}
    L_0 = liouvillian(H_0)
    L_p = liouvillian(H_p)
    L_m = liouvillian(H_m)

    return steadystate(liouvillian_floquet(L_0, L_p, L_m, ω, n_max = n_max, tol = tol), solver = ss_solver)
end
