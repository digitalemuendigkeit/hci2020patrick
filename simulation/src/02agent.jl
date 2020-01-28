mutable struct Agent
    id::Int64
    opinion::Float64
    inclin_interact::Float64
    perceiv_publ_opinion::Float64
    inactive_ticks::Int16
    feed::Array{Post, 1}
    function Agent(id, opinion, rng)
        # check if opinion value is valid
        if opinion < -1 || opinion > 1
            error("invalid opinion value")
        end

        new(
            id,
            opinion,
            generate_inclin_interact(rng),
            opinion,
            0,
            Array{Post, 1}(undef, 0)
        )
    end
end

# suppress output of include()
;
