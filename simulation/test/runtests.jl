include(joinpath("..", "src", "simulation.jl"))
include(joinpath("..", "src", "03runeval.jl"))

################################################################################
####                Calculate CSV for results evaluation in R               ####

results = DataFrame(
    BatchName = String[],
    ConfigAgentCount = Int64[],
    ConfigUnfriendThresh = Float64[],
    ConfigAddfriendMethod = String[],
    Densities = Float64[],
    OutdegreeSD = Float64[],
    IndegreeSD = Float64[],
    OutdegreeIndegreeRatioMean = Float64[],
    ClosenessCentralityMean = Float64[],
    BetweennessCentralityMean = Float64[],
    EigenCentralityMean = Float64[],
    ClustCoeff = Float64[],
    CommunityCount = Int64[],
    CommunityCountNontrivial = Int64[],
    ConnectedComponents = Int64[],
    OpinionSD = Float64[],
    OpChangeDeltaMean = Float64[],
    PublOwnOpinionDiff = Float64[],
    SupernodeOutdegree = Int64[],
    SupernodeCloseness = Float64[],
    SupernodeBetweenness = Float64[],
    SupernodeEigen = Float64[],
    SupernodeOpinion = Float64[],
    Supernode1st2ndOpdiff = Float64[],
    CommunityOpMeanSDs = Float64[]
)

for file in readdir("results")
    if (
        (occursin("Netsize", file) || occursin("Addfriends", file) || occursin("Unfriend", file))
        && occursin(".jld2", file) && !occursin("singlerun", file)
    )
        raw = load(joinpath("results", file))
        current_run = raw[first(keys(raw))]
        repcount = length(current_run)
        nodes_ranked = [first.(sort([(i, outdegree(current_run[j].final_state[1], i)) for i in 1:nv(current_run[j].final_state[1])], by=last, rev=true)) for j in 1:repcount]

        opinionsd = [std([agent.opinion for agent in current_run[i].final_state[2]]) for i in 1:repcount]
        opchange_delta_mean = [mean([abs(current_run[j].init_state[2][i].opinion - current_run[j].final_state[2][i].opinion) for i in 1:current_run[j].config.network.agent_count]) for j in 1:repcount]
        densities = [density(current_run[i].final_state[1]) for i in 1:repcount]
        outdegree_sd = [std(outdegree(current_run[i].final_state[1])) for i in 1:repcount]
        outdegree_mean = [mean(outdegree(current_run[i].final_state[1])) for i in 1:repcount]
        indegree_sd = [std(indegree(current_run[i].final_state[1])) for i in 1:repcount]
        outinratio = [mean([outdegree(current_run[i].final_state[1], j) / degree(current_run[i].final_state[1], j) for j in 1:nv(current_run[i].final_state[1]) if degree(current_run[i].final_state[1], j) > 0]) for i in 1:repcount]
        publownopiniondiff = [mean([abs(agent.perceiv_publ_opinion - agent.opinion) for agent in current_run[i].final_state[2]]) for i in 1:repcount]
        closeness_centrality_mean = [mean(closeness_centrality(current_run[i].final_state[1])) for i in 1:repcount]
        betweenness_centrality_mean = [mean(betweenness_centrality(current_run[i].final_state[1])) for i in 1:repcount]
        eigen_centrality_mean = [mean(eigenvector_centrality(current_run[i].final_state[1])) for i in 1:repcount]
        supernode_outdegree = [outdegree(current_run[i].final_state[1], nodes_ranked[i][1]) for i in 1:repcount]
        supernode_closeness = [closeness_centrality(current_run[i].final_state[1])[nodes_ranked[i][1]] for i in 1:repcount]
        supernode_betweenness = [betweenness_centrality(current_run[i].final_state[1])[nodes_ranked[i][1]] for i in 1:repcount]
        supernode_eigen = [eigenvector_centrality(current_run[i].final_state[1])[nodes_ranked[i][1]] for i in 1:repcount]
        supernode_opinion = [current_run[i].final_state[2][nodes_ranked[i][1]].opinion for i in 1:repcount]
        supernode1st2nd_opdiff = [abs(current_run[i].final_state[2][nodes_ranked[i][1]].opinion - current_run[i].final_state[2][nodes_ranked[i][2]].opinion) for i in 1:repcount]
        clust_coeff = [global_clustering_coefficient(current_run[i].final_state[1]) for i in 1:repcount]
        conn_components = [length(connected_components(current_run[i].final_state[1])) for i in 1:repcount]

        # Calc the SD of the opinion means of the identified clusters
        n_communities = Int64[]
        community_opinion_mean_sds = Float64[]
        n_communities_nontrivial = Int64[]
        for i in 1:repcount
            label_prop = label_propagation(current_run[i].final_state[1])[1]
            community_sizes = last.(collect(countmap(label_prop)))
            push!(n_communities_nontrivial, length([i for i in community_sizes if i > 1]))
            push!(n_communities, maximum(label_prop))
            if maximum(label_prop) == 1
                push!(community_opinion_mean_sds, 0)
                continue
            end
            push!(community_opinion_mean_sds, std([mean([agent.opinion for agent in current_run[i].final_state[2] if agent.id in findall(x->x==j, label_prop)]) for j in 1:maximum(label_prop)]))
        end

        append!(
            results,
            DataFrame(
                BatchName = file[1:first(findfirst("_", file)) - 1],
                ConfigAgentCount = current_run[1].config.network.agent_count,
                ConfigUnfriendThresh = current_run[1].config.opinion_threshs.unfriend,
                ConfigAddfriendMethod = current_run[1].config.simulation.addfriends,
                Densities = densities,
                OutdegreeSD = outdegree_sd,
                IndegreeSD = indegree_sd,
                OutdegreeIndegreeRatioMean = outinratio,
                ClosenessCentralityMean = closeness_centrality_mean,
                BetweennessCentralityMean = betweenness_centrality_mean,
                EigenCentralityMean = eigen_centrality_mean,
                ClustCoeff = clust_coeff,
                CommunityCount = n_communities,
                CommunityCountNontrivial = n_communities_nontrivial,
                ConnectedComponents = conn_components,
                OpinionSD = opinionsd,
                OpChangeDeltaMean = opchange_delta_mean,
                PublOwnOpinionDiff = publownopiniondiff,
                SupernodeOutdegree = supernode_outdegree,
                SupernodeCloseness = supernode_closeness,
                SupernodeBetweenness = supernode_betweenness,
                SupernodeEigen = supernode_eigen,
                SupernodeOpinion = supernode_opinion,
                Supernode1st2ndOpdiff = supernode1st2nd_opdiff,
                CommunityOpMeanSDs = community_opinion_mean_sds
            )
        )
    end
end

using CSV

CSV.write("results.csv", results)

####                                                                        ####
################################################################################

################################################################################
####                Generate Prototype Data for batchruns                   ####

for file in readdir("results")
    if (
            (
                occursin("Netsize", file)
                || occursin("Addfriends", file)
                || occursin("Unfriend", file)
            )
            && occursin(".jld2", file)
            && !occursin("singlerun", file)
        )

        raw = load(joinpath("results", file))
        current_run = raw[first(keys(raw))]

        prototype = rerun_single(get_prototype(current_run))

        CSV.write(
            joinpath("results", "$(prototype.name)_prototype_agent_log" * ".csv"),
            prototype.agent_log
        )

        CSV.write(
            joinpath("results", "$(prototype.name)_prototype_agent_communities" * ".csv"),
            prototype.final_state[3]
        )

        savegraph(
            joinpath("results", "$(prototype.name)_prototype_graph.gml"),
            prototype.final_state[1],
            GraphIO.GML.GMLFormat()
        )
    end
end

####                                                                        ####
################################################################################
