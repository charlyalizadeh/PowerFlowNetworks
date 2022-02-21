function unique_rows(A::AbstractMatrix{T}; col=1) where T
    # This a very naive implementation
    size(A, 1) in (0, 1) && return A
    delete_rows = []
    for i in 2:size(A, 1)
        if A[i, col] == A[i - 1, col]
            push!(delete_rows, i)
        end
    end
    keep_rows = map(x -> !(x in delete_rows), 1:size(A, 1))
    return A[keep_rows, :]
end
