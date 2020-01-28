function create_agents(graph::AbstractGraph, rng::MersenneTwister)

    agent_list = Array{Agent, 1}(undef, length(vertices(graph)))
    for agent_idx in 1:length(agent_list)
        agent_list[agent_idx] = Agent(
            agent_idx,
            2 * rand(rng) - 1,
            rng
        )
    end
    return agent_list
end

# suppress output of include()
;

function generate_inclin_interact(rng::MersenneTwister, lambda=log(25))
    # this function was adapted from:
    # https://www.johndcook.com/julia_rng.html
    if lambda <= 0.0
        error("mean must be positive")
    end
    -(1 / lambda) * log(rand(rng))
end
