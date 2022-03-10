include("cholesky.jl")
include("elimination_game.jl")
include("lex_m.jl")
include("mcs_m.jl")
include("minimum_degree.jl")

const chordal_extension_func = Dict(
    "cholesky" => choleskydec,
    "minimum_degree" => minimum_degree,
    "mcs_m" => mcs_m,
    "lex_m" => lex_m,
    "elimination_game" => elimination_game
)


function chordal_extension(g::AbstractGraph, extension_alg::AbstractString; kwargs...)
    return chordal_extension_func[extension_alg](g; kwargs...)
end
