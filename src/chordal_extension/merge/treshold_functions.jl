function treshold_array_length_up(array, treshold)
    return size(array, 1) > treshold
end

function treshold_array_length_down(array, treshold)
    return size(array, 1) < treshold
end

function treshold_clique_nv_up(merge_kwargs)
    return merge_kwargs_2 -> treshold_array_length_up(merge_kwargs_2["clique"], merge_kwargs["treshold_percent"] * get_nv(merge_kwargs["clique"]))
end

function treshold_cliquetree_nv_up(merge_kwargs)
    return merge_kwargs_2 -> treshold_array_length_up(merge_kwargs_2["clique"], merge_kwargs["treshold_percent"] * get_nv(merge_kwargs["cliquetree"]))
end

function treshold_clique_ne_up(merge_kwargs)
    return merge_kwargs_2 -> treshold_array_length_up(merge_kwargs_2["clique"], merge_kwargs["treshold_percent"] * get_ne(merge_kwargs["clique"]))
end

function treshold_cliquetree_ne_up(merge_kwargs)
    return merge_kwargs_2 -> treshold_array_length_up(merge_kwargs_2["clique"], merge_kwargs["treshold_percent"] * get_ne(merge_kwargs["cliquetree"]))
end

function treshold_nb_lc_nv_up(merge_kwargs)
    return merge_kwargs_2 -> merge_kwargs_2["nb_lc"] > merge_kwargs["treshold_percent"] * get_nv(merge_kwargs["clique"])
end

function treshold_nb_lc_ne_up(merge_kwargs)
    return merge_kwargs_2 -> merge_kwargs_2["nb_lc"] > merge_kwargs["treshold_percent"] * get_ne(merge_kwargs["clique"])
end


const treshold_functions = Dict(
    "clique_nv_up" => treshold_clique_nv_up,
    "cliquetree_nv_up" => treshold_cliquetree_nv_up,
    "clique_ne_up" => treshold_clique_ne_up,
    "cliquetree_ne_up" => treshold_cliquetree_ne_up,
    "nb_lc_nv_up" => treshold_nb_lc_nv_up,
    "nb_lc_ne_up" => treshold_nb_lc_ne_up
)
