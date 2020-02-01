using LightGraphs
using DataFrames
using Random
using Statistics
using JLD
using JLD2
using StatsBase
using CSV
using GraphIO

for script in readdir("src")
    if script != "simulation.jl" && script != "03runeval.jl"
        include(script)
    end
end

mutable struct Simulation

    name::String
    runnr::Int64
    repnr::Int64
    rng::MersenneTwister
    config::Config
    init_state::Any
    final_state::Any
    agent_log::DataFrame
    post_log::Any
    graph_list::Array{AbstractGraph}

    function Simulation(config=Config())
        new(
            "",
            0,
            0,
            MersenneTwister(),
            config,
            (nothing, nothing),
            (nothing, nothing),
            DataFrame(),
            DataFrame(),
            Array{AbstractGraph, 1}(undef, 0)
        )
    end

    function Simulation(sim_transferred::Tuple{String,Int64,Int64,MersenneTwister,Config,Tuple{SimpleDiGraph{Int64},Array{Agent,1}},Tuple{SimpleDiGraph{Int64},Array{Agent,1}},DataFrame,DataFrame,Array{AbstractGraph,1}})
        new(
            sim_transferred[1],
            sim_transferred[2],
            sim_transferred[3],
            sim_transferred[4],
            sim_transferred[5],
            sim_transferred[6],
            sim_transferred[7],
            sim_transferred[8],
            sim_transferred[9],
            sim_transferred[10]
        )
    end

end



function tick!(
    state::Tuple{AbstractGraph, AbstractArray},
    tick_nr::Int64, config::Config, rng::MersenneTwister
)
    agent_list = state[2]
    if config.simulation.agent_logging
        prev_state = deepcopy(state)
    end

    for agent_idx in shuffle(rng, 1:length(agent_list))
        this_agent = agent_list[agent_idx]
        update_feed!(state, agent_idx, config)
        update_perceiv_publ_opinion!(state, agent_idx)
        update_opinion!(state, agent_idx, config)

        drop_friends!(state, agent_idx, config)
        if indegree(state[1], agent_idx) < config.network.m0
            if config.simulation.addfriends == "neighborsofneighbors"
                add_friends_neighbors_of_neighbors!(
                    state, agent_idx,
                    config, config.network.new_follows, rng
                )
            elseif config.simulation.addfriends == "random"
                add_friends_random!(
                    state, agent_idx,
                    config, config.network.new_follows
                )
            else
                add_friends_neighbors_of_neighbors!(
                    state, agent_idx,
                    config, floor(Int,config.network.new_follows/2), rng
                )
                add_friends_random!(
                    state, agent_idx,
                    config, floor(Int,config.network.new_follows/2)
                )
            end
        end

        inclin_interact = deepcopy(this_agent.inclin_interact)
        while inclin_interact > 0
            if rand() < inclin_interact
                publish_post!(state, agent_idx, rng, tick_nr)
            end
            inclin_interact -= 1.0
        end
    end

    if config.simulation.agent_logging
        return log_network(state, prev_state, tick_nr)
    else
        return state
    end
end

function run!(
    simulation::Simulation;
    name::String = "result"
)
    if name * ".jld2" in readdir("results")
        raw = load(joinpath("results", name * ".jld2"))
        rep = raw[first(keys(raw))]
    else
        rep = Simulation[]
    end

    config = simulation.config
    simulation.name = name


    for current_rep in 1:config.simulation.repcount

        simulation.repnr = length(rep) + 1

        simulation.rng = Random.seed!(sum(codeunits(name)) + simulation.repnr)

        graph = SimpleDiGraph(barabasi_albert(
                        config.network.agent_count,
                        config.network.m0))
        simulation.init_state = (graph, create_agents(graph, simulation.rng))
        state = deepcopy(simulation.init_state)

        if config.simulation.agent_logging
            simulation.agent_log = DataFrame(
            TickNr = 0,
            AgentID = [agent.id for agent in state[2]],
            Opinion = [agent.opinion for agent in state[2]]
            )
        end

        for i in 1:config.simulation.ticks

            if config.simulation.agent_logging
                append!(simulation.agent_log, tick!(state, i, config, simulation.rng))
            else
                tick!(state, i, config, simulation.rng)
            end

            if i % ceil(config.simulation.ticks / 10) == 0
                if name != "result"
                    print(".")
                end
            end
        end

        simulation.final_state = state

        push!(rep, deepcopy(simulation))
    end

    if !in("results", readdir())
        mkdir("results")
    end
    save(joinpath("results", name * ".jld2"), name, rep)
    # rm(joinpath("tmp", name * ".jld2"))

    print("\n---\nFinished simulation run with the following specifications:\n $config\n---\n")

    return rep
end

function run_batch(
    configlist::Array{Config, 1};
    resume_at::Int64=1,
    stop_at::Int64=length(configlist),
    batch_name::String = ""
)

    for i in resume_at:stop_at
        run_nr = lpad(string(i),length(string(length(configlist))),"0")
        current_sim = Simulation(configlist[i])
        current_sim.runnr = i
        run!(
            current_sim,
            name = (batch_name * "_run$run_nr")
        )
    end
end

function rerun_single(
    simulation_imported::Simulation;
    logging::Bool = true
    )
    simulation = deepcopy(simulation_imported)

    simulation.config = Config(
        network = simulation.config.network,
        simulation = cfg_sim(
            ticks = simulation.config.simulation.ticks,
            addfriends = simulation.config.simulation.addfriends,
            repcount = simulation.config.simulation.repcount,
            agent_logging = logging
        ),
        opinion_threshs = simulation.config.opinion_threshs,
        agent_props = simulation.config.agent_props
    )

    config = simulation.config

    simulation.rng = Random.seed!(simulation.rng.seed)

    graph = SimpleDiGraph(barabasi_albert(
                    config.network.agent_count,
                    config.network.m0))
    simulation.init_state = (graph, create_agents(graph, simulation.rng))
    state = deepcopy(simulation.init_state)

    if config.simulation.agent_logging
        simulation.agent_log = DataFrame(
        TickNr = 0,
        AgentID = [agent.id for agent in state[2]],
        Opinion = [agent.opinion for agent in state[2]],
        OpinionChange = 0.0,
        PerceivPublOpinion = [agent.opinion for agent in state[2]]
        )
    end

    for i in 1:config.simulation.ticks

        if config.simulation.agent_logging
            append!(simulation.agent_log, tick!(state, i, config, simulation.rng))
        else
            tick!(state, i, config, simulation.rng)
        end

        if i % ceil(config.simulation.ticks / 10) == 0
            print(".")
        end
    end

    communities = DataFrame(
        AgentID = 1:length(state[2]),
        Community = label_propagation(state[1])[1]
    )

    simulation.final_state = state[1], state[2], communities

    if !in("results", readdir())
        mkdir("results")
    end
    save(joinpath("results", simulation.name * "_singlerun.jld2"), simulation.name, simulation)
    # rm(joinpath("tmp", name * ".jld2"))

    print("\n---\nFinished simulation run with the following specifications:\n $config\n---\n")

    return simulation
end

# suppress output of include()
;
