include(joinpath("..", "src", "simulation.jl"))

run_resume!()
readdir()
run_batch(reverse(configbatch), batch_name="BAv2")

barabasi_albert(1000, 500)

convert_results()

batchrun = Simulation[]


for file in readdir("results")
    if !occursin("jld2", file)
        continue
    end
    raw = load(joinpath("results", file))
    push!(batchrun, raw[first(keys(raw))])
end

test1 = run!(Simulation(configbatch[10]), name="Performancetest")
run!()

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

    # println(
    #     "Simulation Run $index \n",
    #     "Configuration: $(simulation.config.network.agent_count) Agents, Friend Mode: $(simulation.config.simulation.addfriends), Unfriend Threshold: $(simulation.config.opinion_threshs.unfriend) \n" ,
    #     "Nodes: $(nv(simulation.final_state[1])), Edges: $(ne(simulation.final_state[1])) \n",
    #     "AVG Outdegree: $(mean(outdegree(simulation.final_state[1]))) \n",
    #     "Components of final Graph: $componentsizes \n"
    # )
    # histogram(outdegree(simulation.final_state[1]))
end


using Statistics
using RCall
using Cairo
using Fontconfig

@rput resultcomparison
R"save(resultcomparison,file=\"results.Rda\")"
degree
histogram(mean(indegree(batchrun[18].final_state[1])))
convert_results()
using GraphPlot
using Compose
plot = gplot(batchrun[10].final_state[1])
savefig(plot, "plot.pdf")

draw(PDF("plot.pdf", 16cm, 16cm), gplot(batchrun[10].final_state[1]))

filter(row -> row[:TickNr] == 1000, BArun01.agent_log)[:Opinion]


batchrun = Simulation[]
for i in 1:3
    temp = load(joinpath("results", readdir("results")[i]))
    push!(batchrun, temp[first(keys(temp))])
end


using Plots
histogram([agent.opinion for agent in batchrun[3].final_state[2]], bins = 100)

convert_results(specific_run="BAv2_run03.jld2")

run!(Simulation(configbatch[1]), name="BAv3")

readdir("results")

reverse(collect(1:10))
stop_at = 0
if stop_at == 0
    stop_at = 2
end
for i in 10:-1:1
    print(i)
end


using JLD
using JLD2

configbatch = Config[]
for
    agent_count in [100, 1000],
    unfriend in [0.4, 0.8, 1.2],
    addfriends in ["", "neighborsofneighbors", "random"]

    push!(configbatch, Config(
            network = cfg_net(
                agent_count = agent_count,
                m0 = Int(agent_count/10),
                new_follows = 10
            ),
            simulation = cfg_sim(
                ticks = 100,
                addfriends = addfriends
            ),
            opinion_threshs = cfg_ot(
                backfire = 0.4,
                befriend = 0.2,
                unfriend = unfriend
            ),
            agent_props = cfg_ag(
                own_opinion_weight = 0.95,
                unfriend_rate = 0.05,
                min_friends_count = 5
            )
        )
    )
end


configbatch
