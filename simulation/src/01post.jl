mutable struct Post
    opinion::Float64
    weight::Float64
    source_agent::Int64
    published_at::Int64
    seen_by::Array{Int64, 1}
    function Post(opinion, weight, source_agent, published_at)
        # check if opinion value is valid
        if opinion < -1 || opinion > 1
            error("invalid opinion value")
        end
        if weight < 0
            error("invalid weight value")
        end
        new(
            opinion,
            weight,
            source_agent,
            published_at,
            Int64[]
        )
    end
end

Base.:<(x::Post, y::Post) = x.weight < y.weight

# suppress output of include()
;
