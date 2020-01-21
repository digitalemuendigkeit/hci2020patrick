function update_feed!(
    state::Tuple{AbstractGraph, AbstractArray}, agent_idx::Integer,
    config::Config
)
    graph, agent_list = state
    this_agent = agent_list[agent_idx]
    unique!(this_agent.feed)
    deleted_posts = Integer[]
    for (index, post) in enumerate(this_agent.feed)
        if post.weight == -1 || !(post.source_agent in inneighbors(graph, agent_idx))
            push!(deleted_posts, index)
        else
            post.weight = 0.5 * post.weight
        end
    end
    deleteat!(this_agent.feed, deleted_posts)
    sort!(this_agent.feed, lt=<, rev=true)
    if length(this_agent.feed) > 15
        this_agent.feed = this_agent.feed[1:15]
    end

    for post in this_agent.feed
        if !(agent_idx in post.seen_by)
            push!(post.seen_by, agent_idx)
        end
    end

    return state
end

# suppress output of include()
;
