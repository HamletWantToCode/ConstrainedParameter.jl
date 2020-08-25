# ConstrainedParameter

`ConstrainedParameter.jl` aims to provide user friendly tools to deal with variational paramters that are confined in certain domain, e.g. in Gaussian process, the length scalar is usually required to be positive throughout the optimization. In `ConstrainedParameter.jl`, we assume all parameters to be either variational parameter, constructed by `Parameter`, or invariate parameter, constructed by `Constant`, both of the two type are subtype of `AbstractParameter`. 

```julia
# Unconstrained variational parameter
Parameter(rand(3))

# Positive variational parameter
Parameter(rand(2), Val(:pos))

# Parameter sits in the interval [1.0, 3.0]
using Bijectors: Logit
Parameter(2.0, inv(Logit(1.0, 3.0)))

# constant
Constant(rand(2, 3))

# extract value of an Parameter/Constant
using Test
a = rand(3)
@test value(Parameter(a)) == a
@test value(Constant(a)) == a
```

With the help of `Functors.jl`, we can also flat a `Parameter`/`Constant` type into a named tuple, `functor` method also return a reconstruct method that is able to map the resulting named tuple back to original parameter type. In this way, `ConstainedParameter.jl` is compatible with `Flux.jl`, you just need to substitute the original bare array with `Parameter` type, and `params` will collect all the parameters for you automatically.
