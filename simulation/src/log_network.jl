function log_network(
    state::Tuple{AbstractGraph, AbstractArray}, tick_nr::Int64
)
    graph, agent_list = state
    agent_opinion = [a.opinion for a in agent_list]
    # agent_perceiv_publ_opinion = [a.perceiv_publ_opinion for a in agent_list]
    # agent_indegree = indegree(graph)
    # agent_outdegree = outdegree(graph)
    # agent_centrality = closeness_centrality(graph)
    # agent_cc = local_clustering_coefficient(graph)
    # agent_component = (
    #     [i for i in keys(connected_components(graph)), v in 1:nv(graph)
    #     if v in connected_components(graph)[i]]
    # )

    return DataFrame(
        TickNr = tick_nr,
        AgentID = 1:length(agent_list),
        Opinion = agent_opinion#,
        # PerceivPublOpinion = agent_perceiv_publ_opinion,
        # Indegree = agent_indegree,
        # Outdegree = agent_outdegree,
        # Centrality = agent_centrality,
        # CC = agent_cc#,
        # Component = agent_component
    )
end

# suppress output of include()
;
