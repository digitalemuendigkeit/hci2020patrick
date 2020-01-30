include(joinpath("..", "src", "simulation.jl"))
include(joinpath("..", "src", "03runeval.jl"))

results = DataFrame(
    BatchName = String[],
    ConfigAgentCount = Int64[],
    ConfigUnfriendThresh = Float64[],
    ConfigAddfriendMethod = String[],
    OpinionSD = Float64[],
    OpChangeDeltaMean = Float64[],
    Densities = Float64[],
    OutdegreeSD = Float64[],
    OutdegreeMean = Float64[],
    OutdegreeMax = Float64[],
    IndegreeSD = Float64[],
    IndegreeMean = Float64[],
    SupernodeCentrality = Float64[],
    SupernodeOpinion = Float64[],
    ClustCoeff = Float64[],
    CommunityCount = Int64[],
    ConnectedComponents = Int64[],
    CommunityOpMeanSDs = Float64[]
)

test = load("results/Addfriends_new_run2.jld2")

test = test[first(keys(test))]

test[1]

RunEval(test[1],1)
test2 = rerun_single(test[1], name=test[1].name, rep_nr=1)
RunEval(test2,1)
runevals = RunEval[]

for i in 1:length(test)
    push!(runevals, RunEval(test[i],i))
end

test[minimum([RunEval(test[i], i) - mean(runevals) for i in 1:length(test)]).rep_nr].final_state[2]


for file in readdir("results")
    if (occursin("Netsize", file) || occursin("Addfriends", file) || occursin("Unfriend", file)) && occursin(".jld2", file)
        raw = load(joinpath("results", file))
        current_run = raw[first(keys(raw))]

        prototype = current_run[minimum([RunEval(current_run[i], i) - mean(runevals) for i in 1:length(current_run)]).rep_nr]

        CSV.write(
            joinpath("results", "$(prototype.name)_prototype_agent_log" * ".csv"),
            DataFrame(
                AgentID = [agent.id for agent in prototype.final_state[2]],
                Opinion = [agent.opinion for agent in prototype.final_state[2]]
            )
        )

        savegraph(
            joinpath("results", "$(prototype.name)_prototype_graph.gml"),
            prototype.final_state[1],
            GraphIO.GML.GMLFormat()
        )
    end
end

for file in readdir("results")
    if occursin("Netsize", file) || occursin("Addfriends", file) || occursin("Unfriend", file)
        raw = load(joinpath("results", file))
        current_run = raw[first(keys(raw))]

        addfriends = current_run[1].config.simulation.addfriends == "" ? "hybrid" : current_run[1].config.simulation.addfriends

        opinionsd = [std([agent.opinion for agent in current_run[i].final_state[2]]) for i in 1:50]
        opchange_delta_mean = [mean([abs(current_run[j].init_state[2][i].opinion - current_run[j].final_state[2][i].opinion) for i in 1:current_run[j].config.network.agent_count]) for j in 1:50]
        densities = [density(current_run[i].final_state[1]) for i in 1:50]
        outdegree_sd = [std(outdegree(current_run[i].final_state[1])) for i in 1:50]
        outdegree_mean = [mean(outdegree(current_run[i].final_state[1])) for i in 1:50]
        outdegree_max = [maximum(outdegree(current_run[i].final_state[1])) for i in 1:50]
        indegree_sd = [std(indegree(current_run[i].final_state[1])) for i in 1:50]
        indegree_mean = [mean(indegree(current_run[i].final_state[1])) for i in 1:50]
        supernode_centrality = [closeness_centrality(current_run[i].final_state[1])[findmax(outdegree(current_run[i].final_state[1]))[2]] for i in 1:50]
        supernode_opinion = [current_run[i].final_state[2][findmax(outdegree(current_run[i].final_state[1]))[2]].opinion for i in 1:50]
        clust_coeff = [global_clustering_coefficient(current_run[i].final_state[1]) for i in 1:50]
        conn_components = [length(connected_components(current_run[i].final_state[1])) for i in 1:50]

        # Calc the SD of the opinion means of the identified clusters
        n_communities = Int64[]
        community_opinion_mean_sds = Float64[]
        for i in 1:50
            label_prop = label_propagation(current_run[i].final_state[1])[1]
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
                OpinionSD = opinionsd,
                OpChangeDeltaMean = opchange_delta_mean,
                Densities = densities,
                OutdegreeSD = outdegree_sd,
                OutdegreeMean = outdegree_mean,
                OutdegreeMax = outdegree_max,
                IndegreeSD = indegree_sd,
                IndegreeMean = indegree_mean,
                SupernodeCentrality = supernode_centrality,
                SupernodeOpinion = supernode_opinion,
                ClustCoeff = clust_coeff,
                CommunityCount = n_communities,
                ConnectedComponents = conn_components,
                CommunityOpMeanSDs = community_opinion_mean_sds
            )
        )
    end
end

results

using CSV

CSV.write("results.csv", results)

using Plots
boxplot((outdegree(netsize_run1[1].final_state[1])))


for file in readdir("results")
    if !occursin("jld2", file)
        continue
        # if file in ("netsize", "addfriends", "unfriend")
        #     for subfile in readdir(joinpath("results", file))
        #
        #         raw = load(joinpath("results", file, subfile))
        #         # raw_sim = raw[first(keys(raw))]
        #         # new_sim = SimulationNew(raw_sim, subfile)
        #         push!(batchrun, raw[first(keys(raw))])
        #     end
        # end
    end
    raw = load(joinpath("results", file))
    push!(batchrun, raw[first(keys(raw))])

    # convert_results(specific_run = file)
end
batchrun

occursin("test", "test2")

relEdgeCount = [ne(batchrun[i].final_state[1]) / (ne(CompleteDiGraph(batchrun[i].config.network.agent_count))) for i in 1:length(batchrun)]
lccs = [mean(local_clustering_coefficient(batchrun[i].final_state[1])) for i in 1:length(batchrun)]
gccs = [global_clustering_coefficient(batchrun[i].final_state[1]) for i in 1:length(batchrun)]
opsd = [std([agent.opinion for agent in batchrun[i].final_state[2]]) for i in 1:length(batchrun)]
outdegree_avg = [std(outdegree(batchrun[i].final_state[1])) for i in 1:length(batchrun)]
[is_connected(batchrun[i].final_state[1]) for i in 1:length(batchrun)]

toptensd = [std(last.(sort([(agent, outdegree(batchrun[i].final_state[1], agent.id)) for agent in batchrun[i].final_state[2]], by = last, rev = true)[1:10])) for i in 1:length(batchrun)]



influencers = [(agent, outdegree(batchrun[5].final_state[1], agent.id)) for agent in batchrun[5].final_state[2] if outdegree(batchrun[5].final_state[1], agent.id) > (mean(outdegree(batchrun[5].final_state[1])) + std(outdegree(batchrun[5].final_state[1])))]
lowlights = [(agent, outdegree(batchrun[5].final_state[1], agent.id)) for agent in batchrun[5].final_state[2] if outdegree(batchrun[5].final_state[1], agent.id) < (mean(outdegree(batchrun[5].final_state[1])) - std(outdegree(batchrun[5].final_state[1])))]
rest = influencers = [(agent, outdegree(batchrun[5].final_state[1], agent.id)) for agent in batchrun[5].final_state[2] if outdegree(batchrun[5].final_state[1], agent.id) > (mean(outdegree(batchrun[5].final_state[1])) - std(outdegree(batchrun[5].final_state[1]))) && outdegree(batchrun[5].final_state[1], agent.id) < (mean(outdegree(batchrun[5].final_state[1])) + std(outdegree(batchrun[5].final_state[1])))]

lccs_mean = mean(local_clustering_coefficient(batchrun[1].final_state[1]))
modularity(Graph(batchrun[1].final_state[1]))
weakly_connected_components(Graph(batchrun[7].final_state[1]))
g = batchrun[14].final_state[1]
diameter((g))
outdegree
using Plots
histogram(degree_histogram(g))
edgeweights = DataFrame(
    RunNr = Int64[],
    EdgeNr = Int64[],
    EdgeSrc = Int64[],
    EdgeDst = Int64[],
    Weight = Int64[]
)

for i in 1:length(batchrun)
    current_graph = deepcopy(batchrun[i].final_state[1])
    undirected_graph = deepcopy(Graph(current_graph))
    for (index, e) in enumerate(edges(undirected_graph))
        if has_edge(current_graph, dst(e), src(e))
            edgeweight = 2
        else
            edgeweight = 1
        end

        append!(
            edgeweights,
            DataFrame(
                RunNr = i,
                EdgeNr = index,
                EdgeSrc = src(e),
                EdgeDst = dst(e),
                Weight = edgeweight
            )
        )
    end

    runnr = "Bafinal_run" * lpad(
        string(i),
        length(string(length(batchrun))),
        "0"
        )

    savegraph(
        joinpath("dataexchange", runnr, "graph_undirected.gml"),
        undirected_graph,
        GraphIO.GML.GMLFormat()
    )
end

using RCall

@rput edgeweights
R"save(edgeweights,file=\"edgeweights.Rda\")"

resultcmp = DataFrame(
    Runname = String[],
    Runnr = Int64[],
    Agentcount = Int64[],
    Edgecount = Int64[],
    RelEdgecount = Float64[],
    OutdegreeAVG = Float64[],
    OutdegreeSD = Float64[],
    OutdegreeMAX = Int64[],
    IndegreeAVG = Float64[],
    IndegreeSD = Float64[],
    IndegreeMAX = Int64[],
    CentralityAVG = Float64[],
    CentralityMAX = Float64[],
    CentralityMIN = Float64[],
    CCAVG = Float64[],
    CCMAX = Float64[],
    OpinionAVG = Float64[],
    OpinionSD = Float64[],
    TopTenOpSD = Float64[]
)


function string_as_varname(s::AbstractString,v::Any)
         s=Symbol(s)
         @eval (($s) = ($v))
end

string_as_varname("test", 42)

sort!(resultcmp, [:Agentcount, :Runname])


for simulation in batchrun
    # componentsizes = ""
    # for i in 1:length(connected_components(simulation.final_state[1]))
    #     componentsizes = componentsizes * "Component No.$i, $(length(connected_components(simulation.final_state[1])[i])) Agents. "
    # end

    if simulation.name == "BA_addfriends"
        name = "Addfriends" * simulation.config.simulation.addfriends
    elseif simulation.name == "BA_netsize"
        name = "Netsize" * string(simulation.config.network.agent_count)
    elseif simulation.name == "BA_unfriend"
        name = "Unfriend" * string(simulation.config.opinion_threshs.unfriend)
    else
        name = simulation.name
    end



    push!(
        resultcmp,
        (
            name,
            simulation.runnr,
            nv(simulation.final_state[1]),
            ne(simulation.final_state[1]),
            ne(simulation.final_state[1]) / (ne(CompleteDiGraph(simulation.config.network.agent_count))),
            mean(outdegree(simulation.final_state[1])),
            std(outdegree(simulation.final_state[1])),
            maximum(outdegree(simulation.final_state[1])),
            mean(indegree(simulation.final_state[1])),
            std(indegree(simulation.final_state[1])),
            maximum(indegree(simulation.final_state[1])),
            mean(closeness_centrality(simulation.final_state[1])),
            maximum(closeness_centrality(simulation.final_state[1])),
            minimum(closeness_centrality(simulation.final_state[1])),
            mean(local_clustering_coefficient(simulation.final_state[1])),
            maximum(local_clustering_coefficient(simulation.final_state[1])),
            mean([agent.opinion for agent in simulation.final_state[2]]),
            std([agent.opinion for agent in simulation.final_state[2]]),
            std(last.(sort([(agent, outdegree(simulation.final_state[1], agent.id)) for agent in simulation.final_state[2]], by = last, rev = true)[1:10]))
        )
    )
end


using Statistics
using RCall
using Cairo
using Fontconfig

@rput resultcmp
R"save(resultcmp,file=\"results.Rda\")"

histogram(mean(indegree(batchrun[18].final_state[1])))
convert_results()
using GraphPlot
using Compose
plot = gplot(batchrun[10].final_state[1])
savefig(plot, "plot.pdf")
