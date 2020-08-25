module ConstrainedParameter

using Bijectors
using Bijectors: Bijector, Identity, Logit
import Functors: functor

export AbstractParameter, Parameter, Constant, value, num_of_param

include("parameters.jl")
include("idset.jl")
include("parameter_count.jl")

end
