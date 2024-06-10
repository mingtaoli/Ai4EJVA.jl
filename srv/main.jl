include("../src/Ai4eJVA.jl")
using .Ai4EJVA
# Ai4eJVA.SetupConfig()
# Ai4eJVA.SetupLog()
# Ai4eJVA.SetupDB()
# Ai4eJVA.SetupTimer()
# Ai4eJVA.SetupDBList()
# Ai4eJVA.CreateTables()
# Ai4eJVA.serve()
Ai4EJVA.julia_main()

joinpath(@__DIR__, "..", "etc", "front-api.yaml")