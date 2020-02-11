include(joinpath("src", "simulation.jl"))
include(joinpath("src", "03runeval.jl"))

run_batch(batch_netsize, batch_name = "Netsize", stop_at = 1)
run_batch(batch_addfriends, batch_name = "Addfriends")
run_batch(batch_unfriend, batch_name = "Unfriend", resume_at=5)


raw = load("results/Addfriends_run1.jld2")

addfriends = raw[first(keys(raw))]

netsize
RunEval(netsize[51])

teest = rerun_single(netsize[51])

RunEval(teest)

batch_netsize = Config[]

for agent_count in 100:100:500

    push!(batch_netsize, Config(
            network = cfg_net(
                agent_count = agent_count,
                m0 = Int(agent_count/10),
                new_follows = 10
            ),
            simulation = cfg_sim(
                ticks = 1000,
                addfriends = "hybrid",
                repcount = 2,
                agent_logging = false
            ),
            opinion_threshs = cfg_ot(
                backfire = 0.4,
                befriend = 0.2,
                unfriend = 0.6
            ),
            agent_props = cfg_ag(
                own_opinion_weight = 0.95,
                unfriend_rate = 0.05,
                min_friends_count = 5
            )
        )
    )
end

batch_unfriend = Config[]

for unfriend in [0.4, 0.6, 0.8, 1.0, 1.2]

    push!(batch_unfriend, Config(
            network = cfg_net(
                agent_count = 500,
                m0 = Int(500/10),
                new_follows = 10
            ),
            simulation = cfg_sim(
                ticks = 1000,
                addfriends = "hybrid",
                repcount = 50,
                agent_logging = false
            ),
            opinion_threshs = cfg_ot(
                backfire = 0.4,
                befriend = 0.2,
                unfriend = unfriend,
            ),
            agent_props = cfg_ag(
                own_opinion_weight = 0.95,
                unfriend_rate = 0.05,
                min_friends_count = 5
            )
        )
    )
end

batch_addfriends = Config[]

for addfriends in ["neighborsofneighbors", "hybrid", "random"]

    push!(batch_addfriends, Config(
            network = cfg_net(
                agent_count = 500,
                m0 = Int(500/10),
                new_follows = 10
            ),
            simulation = cfg_sim(
                ticks = 1000,
                addfriends = addfriends,
                repcount = 50,
                agent_logging = false
            ),
            opinion_threshs = cfg_ot(
                backfire = 0.4,
                befriend = 0.2,
                unfriend = 0.6
            ),
            agent_props = cfg_ag(
                own_opinion_weight = 0.95,
                unfriend_rate = 0.05,
                min_friends_count = 5
            )
        )
    )
end
