function _check_columns(db, table; min_nv=nothing, max_nv=nothing)
    println("Checking missing values of table $table")
    query = "SELECT * FROM $table"
    if !isnothing(min_nv) && !isnothing(max_nv)
         query *= " WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    for col in names(results)
        values = results[!, col]
        nb_missing = sum(map(ismissing, values))
        nb_total = length(values)
        color = nb_missing == 0 ? Symbol("green") : nb_missing == nb_total ? Symbol("red") : Symbol("yellow")
        printstyled("$col: $nb_missing / $nb_total\n"; color=color)
    end
end

function _check_chordality(row)
    ismissing(row[:graph_path]) && return false
    g = loadgraph(row[:graph_path])
    return ischordal(g)
end

function _check_connectivity(row)
    ismissing(row[:graph_path]) && return false
    g = loadgraph(row[:graph_path])
    return is_connected(g)
end

function _check_self_loops(row)
    ismissing(row[:graph_path]) && return false
    g = loadgraph(row[:graph_path])
    return !has_self_loops(g)
end

function _check_index_clique(row)
    if ismissing(row[:clique_path]) || ismissing(row[:cliquetree_path])
        return false
    end
    clique = read_clique(row[:clique_path])
    cliquetree = read_cliquetree(row[:cliquetree_path])
    for edge in cliquetree
        src = clique[edge[1]]
        dst = clique[edge[2]]
        if isempty(intersect(src, dst))
            return false
        end
    end
    return true
end

function _check_source_graph(db, row)
    if ismissing(row[:origin_name]) || ismissing(row[:origin_scenario])
        return false
    end
    results = DBInterface.execute(db, "SELECT graph_path FROM instances WHERE name = '$(row[:origin_name])' AND scenario = $(row[:origin_scenario])") |> DataFrame
    source_graph = loadgraph(results[1, :graph_path])
    g = loadgraph(row[:graph_path])
    source_edges = edges(source_graph)
    g_edges = edges(g)
    return !isequal(source_graph, g) && all(in(g_edges), source_edges) && vertices(g) == vertices(source_graph)
end

function _check_serialize_graph(row)
    ismissing(row[:graph_path]) && return false
    graph_path = row[:graph_path]
    return isfile(graph_path)
end

function _check_serialize_network(row)
    ismissing(row[:pfn_path]) && return false
    pfn_path = row[:pfn_path]
    return isfile(pfn_path)
end

function _check_basic_feature(row)
    return !ismissing(row[:nbus]) &&
           !ismissing(row[:nbranch]) &&
           !ismissing(row[:nbranch_unique]) &&
           !ismissing(row[:ngen])
end

const check_functions = Dict(
    "chordality" => _check_chordality,
    "connectivity" => _check_connectivity,
    "self_loops" => _check_self_loops,
    "index_clique" => _check_index_clique,
    "source_graph" => _check_source_graph,
    "serialize_graph" => _check_serialize_graph,
    "serialize_network" => _check_serialize_network,
    "basic_feature" => _check_basic_feature
)
const need_db = Dict(
    "chordality" => false,
    "connectivity" => false,
    "self_loops" => false,
    "index_clique" => false,
    "source_graph" => true,
    "serialize_graph" => false,
    "serialize_network" => false,
    "basic_feature" => false
)
const valid_check_instance = Dict(
    "chordality" => true,
    "connectivity" => true,
    "self_loops" => true,
    "index_clique" => false,
    "source_graph" => false,
    "serialize_graph" => true,
    "serialize_network" => true,
    "basic_feature" => true,
)
const valid_check_decomposition = Dict(
    "chordality" => true,
    "connectivity" => true,
    "self_loops" => true,
    "index_clique" => true,
    "source_graph" => true,
    "serialize_graph" => true,
    "serialize_network" => false,
    "basic_feature" => false
)

function _check_sanity(db, rows, checks)
    for c in checks
        check_results = nothing
        if need_db[c]
            check_function(row) = check_functions[c](db, row)
            check_results = check_function.(eachrow(rows))
        else
            check_results = check_functions[c].(eachrow(rows))
        end
        if !all(check_results)
            printstyled("$(c) check failed.\n"; color=:red)
        else
            printstyled("$(c).\n"; color=:green)
        end
    end
end

function check_sanity(db::SQLite.DB, checks; min_nv=nothing, max_nv=nothing, subset_instance=nothing, subset_decomposition=nothing)
    _check_columns(db, "instances"; min_nv=min_nv, max_nv=max_nv)
    _check_columns(db, "decompositions"; min_nv=min_nv, max_nv=max_nv)
    query = "SELECT * FROM instances"
    if !isnothing(min_nv) && !isnothing(max_nv)
         query *= " WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    end
    if !isnothing(subset_instance)
        if !isnothing(min_nv) && !isnothing(max_nv)
            query *= " AND id IN ($(join(subset_instance, ',')))"
        else
            query *= " WHERE id IN ($(join(subset_instance, ',')))"
        end
    end
    println(query)
    results = DBInterface.execute(db, query) |> DataFrame
    printstyled("Checking table: instances\n"; bold=true)
    _check_sanity(db, results, filter(c -> valid_check_instance[c], checks))

    query = "SELECT * FROM decompositions"
    if !isnothing(min_nv) && !isnothing(max_nv)
         query *= " WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    end
    if !isnothing(subset_decomposition)
        if !isnothing(min_nv) && !isnothing(max_nv)
            query *= " AND id IN ($(join(subset_decomposition, ',')))"
        else
            query *= " WHERE id IN ($(join(subset_decomposition, ',')))"
        end
    end
    println(query)
    results = DBInterface.execute(db, query) |> DataFrame
    printstyled("\nChecking table: decompositions\n"; bold=true)
    _check_sanity(db, results, filter(c -> valid_check_decomposition[c], checks))
end
