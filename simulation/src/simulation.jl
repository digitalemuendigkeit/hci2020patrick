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
    if script != "simulation.jl"
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
                    state, agent_idx, post_list,
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
    return state
end

function run!(
    simulation::Simulation,
    rng::MersenneTwister;
    name::String = "result"
)
    rep = Simulation[]

    config = simulation.config
    simulation.name = name

    for _ in 1:config.simulation.repcount

        graph = SimpleDiGraph(barabasi_albert(
                        config.network.agent_count,
                        config.network.m0))
        simulation.init_state = (graph, create_agents(graph, rng))
        state = deepcopy(simulation.init_state)

        for i in 1:config.simulation.ticks

            tick!(state, i, config, rng)

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
        rng = Random.seed!(configlist[i].simulation.repcount)
        run_nr = lpad(string(i),length(string(length(configlist))),"0")
        current_sim = Simulation(configlist[i])
        current_sim.runnr = i
        run!(
            current_sim,
            rng,
            name = (batch_name * "_run$run_nr")
        )
    end
end

function run_resume!(
    path::String = "result"
)

    if !("tmp" in readdir())
        mkdir("tmp")
    elseif "tmp" in readdir() && path == "result"
        path = joinpath("tmp", readdir("tmp")[1])
    end

    raw_data = load(path)

    name = (
        path[first(findlast("\\", path))+1:first(findfirst(".jld2", path))-1]
    )


    tick_nr = parse(Int, first(keys(raw_data))) + 1
    simulation = collect(values(raw_data))[1]
    config = simulation.config

    println("Resumed Run: $name \n $config) \n ---")

    for i in 1:Int((ticknr - 1) / config.simulation.ticks * 10)
        print(".")
    end

    state = simulation.final_state
    agent_log = simulation.agent_log
    post_log = simulation.post_log

    for i in tick_nr:config.simulation.ticks

        if name == "result"
            print('\r')
            print(
                "Current Tick: $i, current AVG agents connection count::"
                * string(round(mean(degree(state[1])))) * ", max outdegree: "
                * string(maximum(outdegree(state[1]))) * ", current Posts: "
                * string(length(
                    [post for post in post_log if length(post.seen_by) > 0])
                )
            )
        end

        append!(agent_log, tick!(state, post_log, i, config))

        if i % ceil(config.simulation.ticks / 10) == 0
            if name != "result"
                print(".")
            end

            push!(simulation.graph_list, deepcopy(state[1]))

            simulation.final_state = state
            simulation.agent_log = agent_log
            simulation.post_log = post_log

            save(joinpath("tmp", name * ".jld2"), string(i), simulation)
        end
    end

    simulation.final_state = state
    simulation.agent_log = agent_log
    simulation.post_log = DataFrame(
        Opinion = [p.opinion for p in post_log],
        Weight = [p.weight for p in post_log],
        Source_Agent = [p.source_agent for p in post_log],
        Published_At = [p.published_at for p in post_log],
        Seen = [p.seen_by for p in post_log]
    )

    if !in("results", readdir())
        mkdir("results")
    end
    save(joinpath("results", name * ".jld2"), name, simulation)
    rm(joinpath("tmp", name * ".jld2"))

    if length(readdir("tmp")) == 0
        rm("tmp")
    end

    print(
        "\n---\nFinished simulation run with the following specifications:\n
        $(simulation.config)\n---\n"
    )

    return simulation

end

# suppress output of include()
;
