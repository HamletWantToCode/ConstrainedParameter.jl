function num_of_param(x; seen=IdSet())
    n = 0
    fields, _ = functor(x)
    for f in fields
        n += num_of_param(f, seen=seen)
    end
    return n
end
num_of_param(x::Number; seen=IdSet()) = (push!(seen, x); 1)
function num_of_param(x::AbstractArray{<:Number}; seen=IdSet())
    x in seen && return 0
    n = length(x)
    push!(seen, x)
    return n
end


