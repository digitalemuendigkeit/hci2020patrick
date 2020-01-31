include(joinpath("src", "simulation.jl"))

for file in readdir("results")
    if occursin("transferformat", file) || !occursin(".jld2", file)
        continue
    end
    raw = load(joinpath("results", file))
    current_run = raw[first(keys(raw))]

    current_run_transfer = Tuple{String, Int64, Int64, MersenneTwister, Config, Any, Any, DataFrame, Any, Array{AbstractGraph}}[]

    for i in 1:length(current_run)
        push!(
            current_run_transfer,
            (
                current_run[i].name,
                current_run[i].runnr,
                i,
                MersenneTwister(sum(codeunits(current_run[i].name)) + i),
                current_run[i].config,
                current_run[i].init_state,
                current_run[i].final_state,
                current_run[i].agent_log,
                current_run[i].post_log,
                current_run[i].graph_list
            )
        )
    end

    save(joinpath("results", current_run[1].name * "_transferformat.jld2"), current_run[1].name, current_run_transfer)
end

# Transfer Step 2

for file in readdir("results")
    if !occursin("transferformat", file) || !occursin(".jld2", file)
        continue
    end
    raw = load(joinpath("results", file))
    current_run = raw[first(keys(raw))]

    current_run_transfered = [Simulation(current_run[i]) for i in 1:length(current_run)]

    save(joinpath("results", current_run_transfered[1].name * "_transfered.jld2"), current_run_transfered[1].name, current_run_transfered)
end
