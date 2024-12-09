export plot_wigner

@doc raw"""
    plot_wigner(
        state::QuantumObject{<:AbstractArray{T},OpType}; 
        library::Union{Val,Symbol}=Val(:CairoMakie), 
        kwargs...
    )

Plot the [Wigner quasipropability distribution](https://en.wikipedia.org/wiki/Wigner_quasiprobability_distribution) of `state` using the [`wigner`](@ref) function. 
    
The `library` keyword argument specifies the plotting library to use, defaulting to `CairoMakie`. Note that plotting libraries must first be imported before using them with this function.

# Arguments
- `state::QuantumObject{<:AbstractArray{T},OpType}`: The quantum state for which to plot the Wigner distribution.
- `library::Union{Val,Symbol}`: The plotting library to use. Default is `Val(:CairoMakie)`.
- `kwargs...`: Additional keyword arguments to pass to the plotting function. See the documentation for the specific plotting library for more information.

!!! warning "Beware of type-stability!"
    If you want to keep type stability, it is recommended to use `Val(:CairoMakie)` instead of `:CairoMakie` as the plotting library. See [this link](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-value-type) and the [related Section](@ref doc:Type-Stability) about type stability for more details.
"""
plot_wigner(
    state::QuantumObject{<:AbstractArray{T},OpType};
    library::Union{Val,Symbol} = Val(:CairoMakie),
    kwargs...,
) where {T,OpType<:Union{BraQuantumObject,KetQuantumObject,OperatorQuantumObject}} =
    plot_wigner(makeVal(library), state; kwargs...)

plot_wigner(
    ::Val{T},
    state::QuantumObject{<:AbstractArray{T1},OpType};
    kwargs...,
) where {T,T1,OpType<:Union{BraQuantumObject,KetQuantumObject,OperatorQuantumObject}} = throw(
    ArgumentError(
        "The specified plotting library $T is not available. Try running `using $T` first.",
    ),
)