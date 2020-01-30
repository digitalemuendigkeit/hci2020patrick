mutable struct RunEval
    rep_nr::Int64
    density::Float64
    outdegree_sd::Float64
    outdegree_mean::Float64
    indegree_sd::Float64
    indegree_mean::Float64
    supernode_centrality::Float64
    clust_coeff::Float64
    community_count::Float64
    opinionsd::Float64
    opchange_delta_mean::Float64

    function RunEval(simulation::Simulation, index::Int64)

        Random.seed!(0)
        label_prop = label_propagation(simulation.final_state[1])[1]
        n_communities = maximum(label_prop)
        # if n_communities == 1
        #     community_opinion_mean_sds = 0
        # else
        #     community_opinion_mean_sds = std([mean([agent.opinion for agent in simulation.final_state[2] if agent.id in findall(x->x==j, label_prop)]) for j in 1:maximum(label_prop)])
        # end
        new(
            index,
            density(simulation.final_state[1]),
            std(outdegree(simulation.final_state[1])),
            mean(outdegree(simulation.final_state[1])),
            std(indegree(simulation.final_state[1])),
            mean(indegree(simulation.final_state[1])),
            closeness_centrality(simulation.final_state[1])[findmax(outdegree(simulation.final_state[1]))[2]],
            global_clustering_coefficient(simulation.final_state[1]),
            n_communities,
            std([agent.opinion for agent in simulation.final_state[2]]),
            mean([abs(simulation.init_state[2][i].opinion - simulation.final_state[2][i].opinion) for i in 1:simulation.config.network.agent_count])
        )

    end

    function RunEval(
        rep_nr::Int64,
        density::Float64,
        outdegree_sd::Float64,
        outdegree_mean::Float64,
        indegree_sd::Float64,
        indegree_mean::Float64,
        supernode_centrality::Float64,
        clust_coeff::Float64,
        community_count::Float64,
        opinionsd::Float64,
        opchange_delta_mean::Float64
        )

        new(
            rep_nr,
            density,
            outdegree_sd,
            outdegree_mean,
            indegree_sd,
            indegree_mean,
            supernode_centrality,
            clust_coeff,
            community_count,
            opinionsd,
            opchange_delta_mean
        )
    end

end

Base.:+(runeval1::RunEval, runeval2::RunEval) = RunEval(
        0,
        runeval1.density + runeval2.density,
        runeval1.outdegree_sd + runeval2.outdegree_sd,
        runeval1.outdegree_mean + runeval2.outdegree_mean,
        runeval1.indegree_sd + runeval2.indegree_sd,
        runeval1.indegree_mean + runeval2.indegree_mean,
        runeval1.supernode_centrality + runeval2.supernode_centrality,
        runeval1.clust_coeff + runeval2.clust_coeff,
        runeval1.community_count + runeval2.community_count,
        runeval1.opinionsd + runeval2.opinionsd,
        runeval1.opchange_delta_mean + runeval2.opchange_delta_mean
    )


Base.:-(runeval1::RunEval, runeval2::RunEval) = RunEval(
        runeval1.rep_nr + runeval2.rep_nr,
        abs(runeval1.density - runeval2.density),
        abs(runeval1.outdegree_sd - runeval2.outdegree_sd),
        abs(runeval1.outdegree_mean - runeval2.outdegree_mean),
        abs(runeval1.indegree_sd - runeval2.indegree_sd),
        abs(runeval1.indegree_mean - runeval2.indegree_mean),
        abs(runeval1.supernode_centrality - runeval2.supernode_centrality),
        abs(runeval1.clust_coeff - runeval2.clust_coeff),
        abs(runeval1.community_count - runeval2.community_count),
        abs(runeval1.opinionsd - runeval2.opinionsd),
        abs(runeval1.opchange_delta_mean - runeval2.opchange_delta_mean)
    )


Base.:/(runeval::RunEval, i::Int64) = RunEval(
    0,
    runeval.density / i,
    runeval.outdegree_sd / i,
    runeval.outdegree_mean / i,
    runeval.indegree_sd / i,
    runeval.indegree_mean / i,
    runeval.supernode_centrality / i,
    runeval.clust_coeff / i,
    runeval.community_count / i,
    runeval.opinionsd / i,
    runeval.opchange_delta_mean / i
)

Base.:isless(runeval1::RunEval, runeval2::RunEval) = (
    (runeval1.outdegree_sd + runeval1.outdegree_mean + runeval1.indegree_sd
    + runeval1.indegree_mean + runeval1.supernode_centrality + runeval1.clust_coeff
    + runeval1.community_count + runeval1.opinionsd + runeval1.opchange_delta_mean)
    < (runeval2.outdegree_sd + runeval2.outdegree_mean + runeval2.indegree_sd
    + runeval2.indegree_mean + runeval2.supernode_centrality + runeval2.clust_coeff
    + runeval2.community_count + runeval2.opinionsd + runeval2.opchange_delta_mean)
)

# suppress output of include()
;
