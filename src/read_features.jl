function get_population_stats(population)
    if length(population) > 1
        return maximum(population), minimum(population), mean(population), median(population), var(population)
    else
        val = population[1]
        return val, val, val, val, 0
    end
end
const _single_features_functions_graph = Dict(
    "nb_edge" => (ne, false),
    "nb_vertex" => (nv, false),
    "global_clustering_coefficient" => (global_clustering_coefficient, false),
    "density" => (density, false),
    "diameter" => (diameter, false),
    "radius" => (radius, false),
    "degree" => (degree, true)
)
const _single_features_functions_network = Dict(
    "PD" => (:bus, :PD),
    "QD" => (:bus, :QD),
    "GS" => (:bus, :GS),
    "BS" => (:bus, :BS),
    "VM" => (:bus, :VM),
    "VA" => (:bus, :VA),
    "VMAX" => (:bus, :VMAX),
    "VMIN" => (:bus, :VMIN),
    "PG" => (:gen, :PG),
    "QG" => (:gen, :QG),
    "QMAX" => (:gen, :QMAX),
    "QMIN" => (:gen, :QMIN),
    "PMAX" => (:gen, :PMAX),
    "PMIN" => (:gen, :PMIN),
    "BR_R" => (:branch, :BR_R),
    "BR_X" => (:branch, :BR_X),
    "BR_B" => (:branch, :BR_B)
)
const _single_features_functions_source_path = Dict(
    "nbus" => nbus,
    "nbranch" => nbranch,
    "nbranch_unique" => nbranch_unique,
    "ngen" => ngen_unique
)
const _feature_info_dict = Dict(
    "nb_edge" => (:graph, false),
    "nb_vertex" => (:graph, false),
    "global_clustering_coefficient" => (:graph, false),
    "density" => (:graph, false),
    "diameter" => (:graph, false),
    "radius" => (:graph, false),
    "degree" => (:graph, true),
    "PD" => (:network, true),
    "QD" => (:network, true),
    "GS" => (:network, true),
    "BS" => (:network, true),
    "VM" => (:network, true),
    "VA" => (:network, true),
    "VMAX" => (:network, true),
    "VMIN" => (:network, true),
    "PG" => (:network, true),
    "QG" => (:network, true),
    "QMAX" => (:network, true),
    "QMIN" => (:network, true),
    "PMAX" => (:network, true),
    "PMIN" => (:network, true),
    "BR_R" => (:network, true),
    "BR_X" => (:network, true),
    "BR_B" => (:network, true),
    "nbus" => (:source_path, false),
    "nbranch" => (:source_path, false),
    "nbranch_unique" => (:source_path, false),
    "ngen" => (:source_path, false)
)

# Single features
function get_single_feature_graph(feature_name::AbstractString, g::SimpleGraph)
    feature_tuple = _single_features_functions_graph[feature_name]
    feature = feature_tuple[1](g)
    return !feature_tuple[2] ? feature : get_population_stats(feature)
end
function get_single_feature_network(feature_name::AbstractString, network::PowerFlowNetwork)
    feature_tuple = _single_features_functions_network[feature_name]
    feature = getfield(network, feature_tuple[1])[!, feature_tuple[2]]
    return get_population_stats(feature)
end
function get_single_feature_source_path(feature_name::AbstractString, source_path::AbstractString)
    feature_functions = _single_features_functions_source_path[feature_name]
    feature = feature_functions(source_path)
    return feature
end

# All features
function get_features_graph(g::SimpleGraph)
    degree_max, degree_min, degree_mean, degree_median, degree_var = get_population_stats(degree(g))
    features = Dict(
        "nb_edge" => ne(g),
        "nb_vertex" => nv(g),
        "degree_max" => degree_max,
        "degree_min" => degree_min,
        "degree_mean" => degree_mean,
        "degree_median" => degree_median,
        "degree_var" => degree_var,
        "global_clustering_coefficient" => global_clustering_coefficient(g),
        "density" => density(g),
        "diameter" => diameter(g),
        "radius" => radius(g)
    )
    return features
end
function get_features_opf(network::PowerFlowNetwork)
    # Thanks VIM
    features = Dict()
    # bus
    features["PD_max"], features["PD_min"], features["PD_mean"], features["PD_median"], features["PD_var"] = get_population_stats(network.bus[!, :PD])
    features["QD_max"], features["QD_min"], features["QD_mean"], features["QD_median"], features["QD_var"] = get_population_stats(network.bus[!, :QD])
    features["GS_max"], features["GS_min"], features["GS_mean"], features["GS_median"], features["GS_var"] = get_population_stats(network.bus[!, :GS])
    features["BS_max"], features["BS_min"], features["BS_mean"], features["BS_median"], features["BS_var"] = get_population_stats(network.bus[!, :BS])
    features["VM_max"], features["VM_min"], features["VM_mean"], features["VM_median"], features["VM_var"] = get_population_stats(network.bus[!, :VM])
    features["VA_max"], features["VA_min"], features["VA_mean"], features["VA_median"], features["VA_var"] = get_population_stats(network.bus[!, :VA])
    features["VMAX_max"], features["VMAX_min"], features["VMAX_mean"], features["VMAX_median"], features["VMAX_var"] = get_population_stats(network.bus[!, :VMAX])
    features["VMIN_max"], features["VMIN_min"], features["VMIN_mean"], features["VMIN_median"], features["VMIN_var"] = get_population_stats(network.bus[!, :VMIN])

    # gen
    features["PG_max"], features["PG_min"], features["PG_mean"], features["PG_median"], features["PG_var"] = get_population_stats(network.gen[!, :PG])
    features["QG_max"], features["QG_min"], features["QG_mean"], features["QG_median"], features["QG_var"] = get_population_stats(network.gen[!, :QG])
    features["QMAX_max"], features["QMAX_min"], features["QMAX_mean"], features["QMAX_median"], features["QMAX_var"] = get_population_stats(network.gen[!, :QMAX])
    features["QMIN_max"], features["QMIN_min"], features["QMIN_mean"], features["QMIN_median"], features["QMIN_var"] = get_population_stats(network.gen[!, :QMIN])
    features["PMAX_max"], features["PMAX_min"], features["PMAX_mean"], features["PMAX_median"], features["PMAX_var"] = get_population_stats(network.gen[!, :PMAX])
    features["PMIN_max"], features["PMIN_min"], features["PMIN_mean"], features["PMIN_median"], features["PMIN_var"] = get_population_stats(network.gen[!, :PMIN])

    # branch
    features["BR_R_max"], features["BR_R_min"], features["BR_R_mean"], features["BR_R_median"], features["BR_R_var"] = get_population_stats(network.branch[!, :BR_R])
    features["BR_X_max"], features["BR_X_min"], features["BR_X_mean"], features["BR_X_median"], features["BR_X_var"] = get_population_stats(network.branch[!, :BR_X])
    features["BR_B_max"], features["BR_B_min"], features["BR_B_mean"], features["BR_B_median"], features["BR_B_var"] = get_population_stats(network.branch[!, :BR_B])

    return features
end
function get_features_instance(network::PowerFlowNetwork)
    g = SimpleGraph(network)
    graph_features = get_features_graph(g)
    opf_features = get_features_opf(network)
    features = merge(+, graph_features, opf_features)
    return features
end

function get_clique_features(clique::Vector{Vector{Int}})
    clique_size = [length(c) for c in clique]
    features = Dict()
    features["clique_size_max"], features["clique_size_min"], features["clique_size_mean"], features["clique_size_median"], features["clique_size_var"] = get_population_stats(clique_size)
    return features
end
