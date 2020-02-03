include(joinpath("src", "simulation.jl"))
include(joinpath("src", "03runeval.jl"))

####    Transfering Simulation Structs into new format  ####

# If simulation struct changes, this procedure helps to convert old simulation
# objects into new ones.

for file in readdir("results")
    if occursin("transferformat", file) || !occursin(".jld2", file)
        continue
    end
    raw = load(joinpath("results", file))
    current_run = raw[first(keys(raw))]

    current_run_transfer = Tuple{
        String,
        Int64,
        Int64,
        MersenneTwister,
        Config,
        Any,
        Any,
        DataFrame,
        Any,
        Array{AbstractGraph}
    }[]

    for i in 1:length(current_run)
        push!(
            current_run_transfer,
            (
                current_run[i].name,
                current_run[i].runnr,
                current_run[i].repnr,
                current_run[i].rng,
                current_run[i].config,
                current_run[i].init_state,
                current_run[i].final_state,
                current_run[i].agent_log,
                current_run[i].post_log,
                current_run[i].graph_list
            )
        )
    end

    save(
        joinpath("results", current_run[1].name * "_transferformat.jld2"),
        current_run[1].name, current_run_transfer)
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

####    Appending replications of equal batch simulation runs  ####

# If a batch run shall be continued, this function helps with appending the
# new results to the existing ones. When continuing a batch run on the same
# machine, it will automatically continue with next replication

# To append new results, the existing results should be inside the results
# folder and the new ones in the resultst subfolder "append"

for file in readdir("results")
    if occursin(".jld2", file) && !occursin("appended", file)
        raw = load(joinpath("results", file))
        current_run = raw[first(keys(raw))]
        name = file[1:first(findfirst(".jld2", file))-1]

        raw2 = load(joinpath("results", "append", file))
        appending_run = raw2[first(keys(raw2))]

        if last(current_run).repnr + 1 == first(appending_run).repnr
            append!(current_run, appending_run)
            save(joinpath("results", name * ".jld2"), name, current_run)
        else
            println("Appending runs for $name do not match")
        end

    end
end
