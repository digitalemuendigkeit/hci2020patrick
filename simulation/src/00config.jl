
function cfg_net(
    ;
    agent_count::Int64=10000,
    m0::Int64=100,
    new_follows::Int64=10
)
    return (
        agent_count=agent_count,
        m0=m0,
        new_follows=new_follows
    )
end

function cfg_sim(
    ;
    ticks::Int64=100,
    addfriends::String=""
    )

    return(
        ticks=ticks,
        addfriends=addfriends
    )
end

function cfg_ot(
    ;
    backfire::Float64=0.4,
    befriend::Float64=0.2,
    unfriend::Float64=0.6
)
    return (
        backfire=backfire,
        befriend=befriend,
        unfriend=unfriend
    )
end

function cfg_ag(
    ;
    own_opinion_weight::Float64=0.90,
    unfriend_rate::Float64=0.05,
    min_friends_count::Int64=5
    )

    return (
        own_opinion_weight=own_opinion_weight,
        unfriend_rate=unfriend_rate,
        min_friends_count=min_friends_count
    )
end

struct Config
    network::NamedTuple{
        (:agent_count, :m0, :new_follows),
        NTuple{3,Int64}
    }
    simulation::NamedTuple{
    (:ticks, :addfriends),
    <:Tuple{Int64, String}
    }
    opinion_threshs::NamedTuple{
        (:backfire, :befriend, :unfriend),
        NTuple{3,Float64}
    }
    agent_props::NamedTuple{
    (:own_opinion_weight, :unfriend_rate, :min_friends_count),
    <:Tuple{Float64, Float64, Int64}
    }

    # constructor
    function Config(
        ;
        network = cfg_net(),
        simulation = cfg_sim(),
        opinion_threshs = cfg_ot(),
        agent_props = cfg_ag()
    )
        new(network, simulation, opinion_threshs, agent_props)
    end
end
