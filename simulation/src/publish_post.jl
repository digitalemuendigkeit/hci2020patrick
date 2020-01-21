function publish_post!(
    state::Tuple{AbstractGraph, AbstractArray}, post_list::AbstractArray, agent_idx::Integer,
    tick_nr::Integer=0
)
    graph, agent_list = state
    this_agent = agent_list[agent_idx]
    post_opinion = this_agent.opinion + 0.1 * (2 * rand() - 1)
    # upper opinion limit is 1
    if post_opinion > 1
        post_opinion = 1.0
    # lower opinion limit is -1
    elseif post_opinion < -1
        post_opinion = -1.0
    end
    post = Post(post_opinion, outdegree(graph, agent_idx), agent_idx, tick_nr)
    push!(post_list, post)
    # send post to each neighbors
    for neighbor in neighbors(graph, agent_idx)
        push!(agent_list[neighbor].feed, post)
    end
    return state, post_list
end

# suppress output of include()
;
