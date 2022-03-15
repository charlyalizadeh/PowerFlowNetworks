include("cholesky.jl")
include("elimination_game.jl")
include("lex_m.jl")
include("mcs_m.jl")
include("minimum_degree.jl")

const chordal_extension_functions = Dict(
    "cholesky" => choleskydec,
    "minimum_degree" => minimum_degree,
    "mcs_m" => mcs_m,
    "lex_m" => lex_m,
    "elimination_game" => elimination_game
)


function chordal_extension(g::AbstractGraph, extension_alg::AbstractString; kwargs...)
    chordal_g, data = chordal_extension_functions[extension_alg](g; kwargs...)
    for v in vertices(chordal_g)
        rem_edge!(chordal_g, v, v)
    end
    return chordal_g, data
end
