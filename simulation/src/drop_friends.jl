function drop_friends!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer,
    config::Config
)
    graph, agent_list = state
    this_agent = agent_list[agent_idx]
    # look for current input posts that have too different opinion compared to own
    # and remove them if source agent opinion is also too different
    unfriend_candidates = Array{Tuple{Int64, Int64}, 1}()
    for post in this_agent.feed
        if abs(post.opinion - this_agent.opinion) > config.opinion_threshs.unfriend
            if abs(agent_list[post.source_agent].opinion - this_agent.opinion) > config.opinion_threshs.unfriend
                # Remove agents with higher follower count than own only with certain probability?
                if (outdegree(graph, post.source_agent) / outdegree(graph, agent_idx) > 1 && rand() > 0.5)
                    push!(unfriend_candidates, (post.source_agent, indegree(graph, post.source_agent)))
                elseif (outdegree(graph, post.source_agent) / outdegree(graph, agent_idx) <= 1)
                    push!(unfriend_candidates, (post.source_agent, indegree(graph, post.source_agent)))
                end
                push!(unfriend_candidates, (post.source_agent, degree(graph, post.source_agent)))
            end
        end
    end
    sort!(unfriend_candidates, by=last)
    for i in 1:min(length(unfriend_candidates), ceil(Int64, indegree(graph,agent_idx) * config.agent_props.unfriend_rate))
        rem_edge!(graph, unfriend_candidates[i][1],agent_idx)
    end
    return state
end

# suppress output of include()
;
