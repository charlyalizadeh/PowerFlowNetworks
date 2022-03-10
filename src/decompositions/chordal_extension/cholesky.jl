function choleskydec(g::AbstractGraph; kwargs...)
    matrix, permutation, nb_added_edges = choleskyfact(g)
    data = Dict("matrix" => matrix,
                "permutation" => permutation,
                "nb_added_edges" => nb_added_edges)
    return SimpleGraph(matrix), data
end

function sparsity_pattern(g::AbstractGraph)
    sparsity_pattern = adjacency_matrix(g)
    for i in 1:nv(g)
        sparsity_pattern[i, i] = length(neighbors(g, i)) + 1
    end
    return sparsity_pattern
end

function choleskyfact(g::AbstractGraph; kwargs...)
    A = sparsity_pattern(g)
    nb_edges_A = (nnz(A) - size(A, 1)) / 2
    # NOTE: AMD ordering by default
    F = cholesky(A; kwargs...) #NOTE: order = F.p
    # computing L + LT
    L = sparse(F.L)
    nb_edges_L = nnz(L) - size(A,1)
    nb_added_edges = nb_edges_L - nb_edges_A
    SP = L + L'
    #inverting permutation to get chordal extension of sparsity_pattern
    H = SP[invperm(F.p), invperm(F.p)]
    return H, F.p, nb_added_edges
end
