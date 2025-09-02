using Documenter, Coefplots

makedocs(
    modules = [Coefplots],
    sitename = "Coefplots.jl",
    doctest = true,
    checkdocs = :none,
    pages = Any[
        "Home" => "index.md",
        "Manual" => ["manual/quick_start.md",
                     "manual/multi_dimension.md",
                     "manual/appearence.md",
                     "manual/utilities.md",
                     "manual/event_study.md"],
        "API" => ["api/types.md",
                  "api/functions.md"]
    ]
)

@info "calling deploydocs"
deploydocs(
    repo = "github.com/caibengbu/Coefplots.jl", 
    devbranch = "main",
    deploy_config = Documenter.GitHubActions(),  
    push_preview = true,                          
)
