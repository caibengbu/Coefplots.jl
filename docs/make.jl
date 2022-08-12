using Documenter, Coefplots

makedocs(
    modules = [Coefplots],
    sitename = "Coefplots.jl",
    doctest = true,
    strict = true,
    checkdocs = :none,
    pages = Any[
        "Home" => "index.md",
        "Manual" => ["manual/quick_start.md",
                     "manual/multi_dimension.md",
                     "manual/appearence.md",
                     "manual/utilities.md"],
        "API" => ["api/types.md",
                  "api/functions.md"]
    ]
)

@info "calling deploydocs"

deploydocs(
    repo = "github.com/caibengbu/Coefplots.jl.git",
    push_preview=true,
)