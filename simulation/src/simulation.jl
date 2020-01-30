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
            config,
            (nothing, nothing),
            (nothing, nothing),
            DataFrame(),
            DataFrame(),
            Array{AbstractGraph, 1}(undef, 0)
        )
    end
end



function tick!(
    state::Tuple{AbstractGraph, AbstractArray},
    tick_nr::Int64, config::Config, rng::MersenneTwister
)
    agent_list = state[2]
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
        return log_network(state, tick_nr)
    else
        return state
    end
end

function run!(
    simulation::Simulation;
    name::String = "result"
)
    rep = Simulation[]

    config = simulation.config
    simulation.name = name


    for current_rep in 1:config.simulation.repcount

        rng = Random.seed!(sum(codeunits(name)) + current_rep)

        graph = SimpleDiGraph(barabasi_albert(
                        config.network.agent_count,
                        config.network.m0))
        simulation.init_state = (graph, create_agents(graph, rng))
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
                append!(simulation.agent_log, tick!(state, i, config, rng))
            else
                tick!(state, i, config, rng)
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
    simulation::Simulation;
    name::String = "result",
    rep_nr::Int64 = 0
    )

    config = simulation.config
    simulation.name = name

    rng = Random.seed!(sum(codeunits(name)) + rep_nr)

    graph = SimpleDiGraph(barabasi_albert(
                    config.network.agent_count,
                    config.network.m0))
    simulation.init_state = (graph, create_agents(graph, rng))
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
            append!(simulation.agent_log, tick!(state, i, config, rng))
        else
            tick!(state, i, config, rng)
        end

        if i % ceil(config.simulation.ticks / 10) == 0
            if name != "result"
                print(".")
            end
        end
    end

    simulation.final_state = state

    if !in("results", readdir())
        mkdir("results")
    end
    save(joinpath("results", name * "_singlerun.jld2"), name, simulation)
    # rm(joinpath("tmp", name * ".jld2"))

    print("\n---\nFinished simulation run with the following specifications:\n $config\n---\n")

    return simulation
end

# suppress output of include()
;
