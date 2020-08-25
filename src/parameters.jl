abstract type AbstractParameter{T} end
const AP{T} = AbstractParameter{T}

# interface
value(::AP) = throw("Not implemented yet")
Base.eltype(::AP{T}) where {T} = T
Base.length(p::AP) = length(value(p))
Base.size(p::AP) = size(value(p))

# Sometime when setup our models, we require it's parameters to follow
# certain constrains, e.g. the support for scaling factor `σ` & length scale `l`
# of a GP kernel should be ℜ⁺, however, adding those constrains make the optimization
# process less convenient. `Parameter` is used to handle this, it's bijector is used
# to map constrained variable to unconstrained one, which is then used during the optimization,
# the inverse of the bijector does the reverse, which will provide us with the constrained
# variables we need.
struct Parameter{T, N, fT} <: AP{T}
    x::AbstractArray{T}
    f::fT
    
    # parameters with single constraint
    function Parameter{T}(y, f::fT) where {T<:Real, N, fT<:Bijector{N}}
        x = inv(f)(y)
        if N == 0
            return new{T, 0, fT}(T[x], f)
        else
            return new{T, N, fT}(x, f)
        end
    end

    # a set of scalar parameter with multiple constraints
    function Parameter{T}(y::Vector{T}, fs::Bijector{0}...) where {T<:Real}
        length(y) != length(fs) && throw(error("Number of parameters and Bijectors must match !"))
        x = map((f,z)->inv(f)(z), fs, y)
        return new{T, 0, typeof(fs)}(x, fs)
    end
end

Base.:(==)(p1::Parameter{T, N, fT}, p2::Parameter{T, N, fT}) where {T, N, fT} = p1.x==p2.x
Base.:(==)(p1::Parameter{T1, N1, fT1}, p2::Parameter{T2, N2, fT2}) where {T1, N1, fT1, T2, N2, fT2} = false

# functor is used to flatten the `Parameter` into a namedtuple, also with a function to reconstruct from that
# namedtuple to `Parameter`
functor(p::Parameter) = (x=p.x,), x->Parameter(p.f(x...), p.f)
functor(p::Parameter{T, 0}) where {T} = (x=p.x,), x->Parameter(p.f(first(x...)), p.f)
functor(p::Parameter{T, 0, S}) where {T, S<:Tuple} = (x=p.x,), x->Parameter(map((f,x)->f(x), p.f, x...), p.f...)

# outer constructor for a set of scalar parameter with multiple constraints
Parameter(y, fs...) = Parameter{eltype(y)}(y, fs...)

# interface
value(y::Parameter) = y.f(y.x)
value(y::Parameter{T, 0}) where {T} = y.f(first(y.x))
value(y::Parameter{T, 0, S}) where {T, S<:Tuple} = map((f, x)->f(x), y.f, y.x)

# if no constrain is added, it will use `Identity` bijector by default
Parameter(y) = Parameter(y, Identity{ndims(y)}())

# if we want positivity constrain, then use `Exp` bijector
Parameter(y, ::Val{:pos}) = Parameter(y, Bijectors.Exp{ndims(y)}())



# `Constant` is used to hold data that we are not intended to optimize
# Note: in QuantumLang, data is either `Parameter` or `Constant`.
struct Constant{T, N} <: AP{T}
    x::AbstractArray{T}

    function Constant{T}(c) where {T}
        N = ndims(c)
        if N == 0
            return new{T, 0}(T[c])
        else
            return new{T, N}(c)
        end
    end
end

Base.:(==)(c1::Constant{T, N}, c2::Constant{T, N}) where {T, N} = c1.x==c2.x
Base.:(==)(c1::Constant{T1, N1}, c2::Constant{T2, N2}) where {T1, N1, T2, N2} = false

functor(c::Constant) = (), _ -> c

Constant(c) = Constant{eltype(c)}(c)

# interface
value(c::Constant{T, 0}) where {T} = first(c.x)
value(c::Constant) = c.x
