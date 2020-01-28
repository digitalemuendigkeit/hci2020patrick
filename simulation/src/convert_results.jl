import ParserCombinator

function convert_results(;sub_path::String="", specific_run::String="")

    if specific_run != ""
        raw_data = load(joinpath("results", specific_run))
        data = raw_data[first(keys(raw_data))]
        filename = specific_run[1:first(findfirst(".jld2", specific_run))-1]

        if !in(filename, readdir("dataexchange"))
                mkdir(joinpath("dataexchange", filename))
        end

        CSV.write(
            joinpath("dataexchange", filename, "agent_log" * ".csv"),
            data.agent_log
        )

        CSV.write(
            joinpath("dataexchange", filename, "post_log" * ".csv"),
            data.post_log
        )

        for i in 1:length(data.graph_list)
            graphnr = lpad(
                string(i),
                length(string(length(data.graph_list))),
                "0"
            )

            savegraph(
                joinpath("dataexchange", filename, "graph_$graphnr.gml"),
                data.graph_list[i],
                GraphIO.GML.GMLFormat()
            )
        end
    else

        if !in("dataexchange", readdir())
                mkdir("dataexchange")
        end

        if sub_path != ""
            path = joinpath("results", sub_path)
        else
            path = "results"
        end

        for file in readdir(path)

            if !occursin("jld2", file)
                continue
            end

            raw_data = load(joinpath(path, file))
            data = raw_data[first(keys(raw_data))]
            filename = file[1:first(findfirst(".jld2", file))-1]

            if !in(filename, readdir("dataexchange"))
                    mkdir(joinpath("dataexchange", filename))
            end

            CSV.write(
                joinpath("dataexchange", filename, "agent_log" * ".csv"),
                data.agent_log
            )

            CSV.write(
                joinpath("dataexchange", filename, "post_log" * ".csv"),
                data.post_log
            )

            savegraph(
                joinpath("dataexchange", filename, "graph_final.gml"),
                data.final_state[1],
                GraphIO.GML.GMLFormat()
            )

            # for i in 1:length(data.graph_list)
            #     graphnr = lpad(
            #         string(i),
            #         length(string(length(data.graph_list))),
            #         "0"
            #     )
            #
            #     savegraph(
            #         joinpath("dataexchange", filename, "graph_$graphnr.gml"),
            #         data.graph_list[i],
            #         GraphIO.GML.GMLFormat()
            #     )
            # end
        end
    end
end
