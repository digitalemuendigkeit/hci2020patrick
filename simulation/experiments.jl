include(joinpath("src", "simulation.jl"))

run_batch(configbatch, batch_name = "BAfinal")
convert_results(specific_run = "BAfinal_run18.jld2")
batchrun[1]
filename = readdir("results")[1]

filename[1:first(findfirst(".jld2", filename))-1]
for (index, sim) in enumerate(batchrun)
    filename = readdir("results")[index]
    save(
        joinpath("results", filename),
        filename[1:first(findfirst(".jld2", filename))-1],
        sim
    )
end

convert_results()

test1 = DiGraph(barabasi_albert(10000,100))
test1 = SimpleDiGraph(barabasi_albert(10000,100))

sizeof(test1)

maximum([agent.inclin_interact for agent in batchrun[26].final_state[2]])

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
                ticks = 1000,
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

configbatch[11]
