dflt = Dict{String, Any}(
    "min_nv" => 100,
    "max_nv" => 500
)

process_kwargs = Dict(
  "save_basic_features_instances" => Dict(),
  "save_single_features_instances" => dflt,
  "save_features_instances" => dflt,
  "serialize_instances" => merge(dflt, Dict("serialize_path" => "data/serialize_networks",
                                             "graphs_path" => "data/graphs")),
  "generate_decompositions" => merge(dflt, Dict("cliques_path" => "data/cliques",
                                                "cliquetrees_path" => "data/cliquetrees",
                                                "graphs_path" => "data/graphs",
                                                "extension_alg" => "cholesky",
                                                "preprocess_path" => "data/configs/preprocess_default.json")),
  "merge_decompositions" => merge(dflt, Dict("heuristic" => ["molzahn"],
                                             "heuristic_switch" => [0],
                                             "treshold_name" => "cliques_nv_up",
                                             "merge_kwargs" => Dict("treshold_percent" => 0.5))),
  "combine_decompositions" => merge(dflt, Dict("how" => "cliques_intersect",
                                               "extension_alg" => "cholesky",
                                               "exclude" => ["combine"])),
)
