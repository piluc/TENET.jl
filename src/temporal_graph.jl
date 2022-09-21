struct temporal_graph
    num_nodes::Int64
    temporal_edges::Array{Tuple{Int64,Int64,Int64}}
    file_id::Array{String}
    file_time::Array{Int64}
end

function load_temporal_graph(file_name::String, sep::String)
    @assert isfile(file_name) "The temporal edge list file does not exist"
    current_node_id::Int64 = 1
    file_id::Vector{String} = []
    file_id_to_graph_id::Dict{String,Int64} = Dict{String,Int64}()
    current_time::Int64 = 1
    file_time::Vector{Int64} = []
    file_time_to_graph_time::Dict{Int64,Int64} = Dict{Int64,Int64}()
    temporal_edges::Array{Tuple{Int64,Int64,Int64}} = []
    t::Int64 = 0
    f::IOStream = open(file_name, "r")
    for line in eachline(f)
        split_line::Vector{String} = split(line, sep)
        @assert length(split_line) == 3 "Bad line format: " * line
        t = parse(Int64, split_line[3])
        if (!haskey(file_id_to_graph_id, split_line[1]))
            file_id_to_graph_id[split_line[1]] = current_node_id
            push!(file_id, split_line[1])
            current_node_id = current_node_id + 1
        end
        if (!haskey(file_id_to_graph_id, split_line[2]))
            file_id_to_graph_id[split_line[2]] = current_node_id
            push!(file_id, split_line[2])
            current_node_id = current_node_id + 1
        end
        if (!haskey(file_time_to_graph_time, t))
            file_time_to_graph_time[t] = current_time
            push!(file_time, t)
            current_time = current_time + 1
        end
    end
    close(f)
    sort!(file_time)
    for t in 1:lastindex(file_time)
        file_time_to_graph_time[file_time[t]] = t
    end
    f = open(file_name, "r")
    for line in eachline(f)
        split_line::Vector{String} = split(line, sep)
        t = parse(Int64, split_line[3])
        push!(temporal_edges, (file_id_to_graph_id[split_line[1]], file_id_to_graph_id[split_line[2]], file_time_to_graph_time[t]))
    end
    sort!(temporal_edges, by=te -> te[3])
    return temporal_graph(length(file_id_to_graph_id), temporal_edges, file_id, file_time)
end

function temporal_adjacency_list(tg::temporal_graph)::Array{Array{Tuple{Int64,Int64}}}
    tal::Array{Array{Tuple{Int64,Int64}}} = Array{Array{Tuple{Int64,Int64}}}(undef, tg.num_nodes)
    for u in 1:tg.num_nodes
        tal[u] = Tuple{Int64,Int64,Int64}[]
    end
    te::Tuple{Int64,Int64,Int64} = (0, 0, 0)
    for i in 1:lastindex(tg.temporal_edges)
        te = tg.temporal_edges[i]
        push!(tal[te[1]], (te[2], te[3]))
    end
    return tal
end

function temporal_neighbors(tal::Array{Array{Tuple{Int64,Int64}}}, u::Int64, t::Int64)::Array{Tuple{Int64,Int64}}
    neig::Array{Tuple{Int64,Int64}} = tal[u]
    left::Int64 = 1
    right::Int64 = length(neig)
    pos::Int64 = length(neig) + 1
    mid::Int64 = -1
    while (left <= right)
        mid = (left + right) ÷ 2
        if (neig[mid][2] <= t)
            left = mid + 1
        else
            pos = mid
            right = mid - 1
        end
    end
    return neig[pos:end]
end
