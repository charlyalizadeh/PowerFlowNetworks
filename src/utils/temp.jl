using SQLite
using DataFrames
include("../../src/PowerFlowNetworks.jl")

function update_preprocess_path(db::SQLite.DB, row)
    preprocess_path = row[:preprocess_path]
    ismissing(preprocess_path) && return
    preprocess_key  = split(splitext(splitpath(preprocess_path)[end])[1], "preprocess")[end][2:end]
    preprocess_path = joinpath(dirname(preprocess_path), "preprocess.toml")
    query = "UPDATE decompositions SET preprocess_path = '$(preprocess_path)', preprocess_key = '$(preprocess_key)' WHERE uuid = '$(row[:uuid])'"
    DBInterface.execute(db, query)
end

function update_preprocess_paths(db::SQLite.DB)
    #DBInterface.execute(db, "ALTER TABLE decompositions ADD COLUMN preprocess_key TEXT")
    results = DBInterface.execute(db, "SELECT * FROM decompositions WHERE preprocess_key IS NULL") |> DataFrame
    func(row) = update_preprocess_path(db, row)
    func.(eachrow(results))
end

db = SQLite.DB("./data/PowerFlowNetworks.sqlite")
update_preprocess_paths(db)
