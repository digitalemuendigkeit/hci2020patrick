function add_friends_neighbors_of_neighbors!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer,
    post_list::AbstractArray,
    config::Config,
    new_friends_count::Int64
)
    graph, agent_list = state
    this_agent = agent_list[agent_idx]
    # neighbors of neighbors
    friend_candidates = Int64[]

    for neighbor in neighbors(graph, agent_idx)
        append!(
            friend_candidates,
            setdiff(
                neighbors(graph, neighbor),
                neighbors(graph, agent_idx),
                agent_idx
            )
        )

    end

    shuffle!(friend_candidates)
    # order neighbors by frequency of occurence in input_candidates descending
    if length(friend_candidates) > 0
        friends_queue = first.(
            sort(collect(countmap(friend_candidates)), by=last, rev=true)
        )

        if (length(friends_queue) - config.network.new_follows) < 0
            new_friends_count = length(friends_queue)

        for _ in 1:new_friends_count
            new_neighbor = popfirst!(friends_queue)
            add_edge!(graph, new_neighbor, agent_idx)
            end
        end
    end

    return state
end

function add_friends_random!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer,
    post_list::AbstractArray,
    config::Config,
    new_friends_count::Int64
    )

    graph, agent_list = state
    this_agent = agent_list[agent_idx]

    friends_queue = Array{Tuple{Int64,Int64}, 1}()
    not_neighbors = setdiff(
        [1:(agent_idx - 1); (agent_idx + 1):nv(graph)], 
        neighbors(graph, agent_idx)
    )

        for candidate in not_neighbors
            if (
                abs(this_agent.opinion - agent_list[candidate].opinion) 
                < config.opinion_threshs.befriend
            )
                push!(friends_queue, (candidate, outdegree(graph, candidate)))
        end
    end

    friends_queue = first.(sort(friends_queue, by=last, rev=true))

    if (length(friends_queue) - config.network.new_follows) < 0
        new_friends_count = length(friends_queue)

    for _ in 1:new_friends_count
        new_neighbor = popfirst!(friends_queue)
        add_edge!(graph, new_neighbor, agent_idx)
        end
    end
    return state
end

# suppress output of include()
;
