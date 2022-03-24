function _check_chordality(row)
    g = loadgraph(row[:graph_path])
    return ischordal(g)
end

function _check_connectivity(row)
    g = loadgraph(row[:graph_path])
    return is_connected(g)
end

function _check_self_loops(row)
    g = loadgraph(row[:graph_path])
    return !has_self_loops(g)
end

function _check_index_clique(row)
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
    results = DBInterface.execute(db, "SELECT graph_path FROM instances WHERE name = '$(row[:origin_name])' AND scenario = $(row[:origin_scenario])") |> DataFrame
    source_graph = loadgraph(results[1, :graph_path])
    g = loadgraph(row[:graph_path])
    source_edges = edges(source_graph)
    g_edges = edges(g)
    return !isequal(source_graph, g) && all(in(g_edges), source_edges) && vertices(g) == vertices(source_graph)
end

const check_functions = Dict(
    "chordality" => _check_chordality,
    "connectivity" => _check_connectivity,
    "self_loops" => _check_self_loops,
    "index_clique" => _check_index_clique,
    "source_graph" => _check_source_graph
)
const need_db = Dict(
    "chordality" => false,
    "connectivity" => false,
    "self_loops" => false,
    "index_clique" => false,
    "source_graph" => true
)
const valid_check_instance = Dict(
    "chordality" => true,
    "connectivity" => true,
    "self_loops" => true,
    "index_clique" => false,
    "source_graph" => false,
)
const valid_check_decomposition = Dict(
    "chordality" => true,
    "connectivity" => true,
    "self_loops" => true,
    "index_clique" => true,
    "source_graph" => true,
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

function check_sanity(db::SQLite.DB, checks; min_nv=typemin(Int), max_nv=typemax(Int), subset_instance=nothing, subset_decomposition=nothing)
    query = "SELECT * FROM instances WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    if !isnothing(subset_instance)
        query *= " AND id IN ($(join(subset_instance, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    printstyled("Checking table: instances\n"; bold=true)
    _check_sanity(db, results, filter(c -> valid_check_instance[c], checks))

    query = "SELECT * FROM decompositions WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    if !isnothing(subset_decomposition)
        query *= " AND id IN ($(join(subset_decomposition, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    printstyled("\nChecking table: decompositions\n"; bold=true)
    _check_sanity(db, results, filter(c -> valid_check_decomposition[c], checks))
end
