include(joinpath("..", "src", "simulation.jl"))

testold = load("results\\old\\BAv2_run10.jld2")

batchrun = Simulation[]

readdir("results")[11]
for file in readdir("results")[11:11]
    if !occursin("jld2", file)
        continue
    end
    raw = load(joinpath("results", file))
    push!(batchrun, raw[first(keys(raw))])
end

resultcomparison = DataFrame(
    AddFriends = String[],
    UnfriendThresh = Float64[],
    Agentcount = Int64[],
    Edgecount = Int64[],
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
    OpinionSD = Float64[]
)

for (index, simulation) in enumerate(batchrun)
    # componentsizes = ""
    # for i in 1:length(connected_components(simulation.final_state[1]))
    #     componentsizes = componentsizes * "Component No.$i, $(length(connected_components(simulation.final_state[1])[i])) Agents. "
    # end

    if simulation.config.simulation.addfriends == ""
        addfriends = "hybrid"
    elseif simulation.config.simulation.addfriends == "neighborsofneighbors"
        addfriends = "NoN"
    else
        addfriends = simulation.config.simulation.addfriends
    end

    push!(
        resultcomparison,
        (
            addfriends,
            simulation.config.opinion_threshs.unfriend,
            nv(simulation.final_state[1]),
            ne(simulation.final_state[1]),
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
            std([agent.opinion for agent in simulation.final_state[2]])
        )
    )
end


using Statistics
using RCall
using Cairo
using Fontconfig

@rput resultcomparison
R"save(resultcomparison,file=\"results.Rda\")"

histogram(mean(indegree(batchrun[18].final_state[1])))
convert_results()
using GraphPlot
using Compose
plot = gplot(batchrun[10].final_state[1])
savefig(plot, "plot.pdf")
