include(joinpath("..", "src", "simulation.jl"))

netsize_run1 = load("results/Netsize_run1.jld2")
netsize_run1 = netsize_run1["Netsize_run1"]
typeof(netsize_run1)

test = ([netsize_run1, netsize_run1])
test
test = Vector{Array{Simulation,1}}
test = Vector{Simulation}[]

push!(test, netsize_run1)

results = DataFrame(
    OpinionSD = Float64[],
    Densities = Float64[],
    OutdegreeSD = Float64[],
    OutdegreeMean = Float64[],
    OutdegreeMax = Float64[],
    IndegreeSD = Float64[],
    IndegreeMean = Float64[],
    Supernode_Centrality = Float64[],
    Clust_Coeff = Float64[],
    AgentsAboveMeanSD = Int64[],
    CommunitiesMax = Int64[]
)

for file in readdir("results")
    if occursin("netsize", file)
        raw = load(joinpath("results", file))
        current_run = raw[first(keys(raw))]

        opinionsd = [std([agent.opinion for agent in current_run[i].final_state[2]]) for i in 1:50]
        densities = [density(current_run[i].final_state[1]) for i in 1:50]
        outdegree_sd = [std(outdegree(current_run[i].final_state[1])) for i in 1:50]
        outdegree_mean = [mean(outdegree(current_run[i].final_state[1])) for i in 1:50]
        outdegree_max = [maximum(outdegree(current_run[i].final_state[1])) for i in 1:50]
        indegree_sd = [std(indegree(current_run[i].final_state[1])) for i in 1:50]
        indegree_mean = [mean(indegree(current_run[i].final_state[1])) for i in 1:50]
        supernode_centrality = [closeness_centrality(current_run[i].final_state[1])[findmax(outdegree(current_run[i].final_state[1]))[2]] for i in 1:50]
        clust_coeff = [global_clustering_coefficient(current_run[i].final_state[1]) for i in 1:50]
        agents_above_meansd = [length([agent for agent in current_run[i].final_state[2] if outdegree(current_run[i].final_state[1], agent.id) > mean(outdegree(current_run[i].final_state[1])) + std(outdegree(current_run[i].final_state[1]))]) for i in 1:50]
        communities_max = [maximum(label_propagation((current_run[i].final_state[1]))[1]) for i in 1:50]

        push!(
            results,
            DataFrame(
                OpinionSD = opinionsd,
                Densities = densities,
                OutdegreeSD = outdegree_sd,
                OutdegreeMean = outdegree_mean,
                OutdegreeMax = outdegree_max,
                IndegreeSD = indegree_sd,
                IndegreeMean = indegree_mean,
                Supernode_Centrality = supernode_centrality,
                Clust_Coeff = clust_coeff,
                AgentsAboveMeanSD = agents_above_meansd,
                CommunitiesMax = communities_max
            )
        )
    end
end

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
