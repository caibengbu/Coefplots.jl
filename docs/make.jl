using Documenter, Coefplots

makedocs(
    modules = [Coefplots],
    sitename = "Coefplots.jl",
    doctest = true,
    strict = true,
    checkdocs = :none,
    pages = Any[
        "Home" => "index.md",
        "Manual" => [],
        "Examples" => []
    ]
)

@info "calling deploydocs"

deploydocs(
    repo = "github.com/caibengbu/Coefplots.jl.git",
    push_preview=true,
)