# include("../src/Coefplots.jl")
# using .Coefplots
using Coefplots
using GLM
using DataFrames, CSV
using Random
using PGFPlotsX
using Test

# this is a utility function to check that two text files are the same
function checkfilesarethesame(file1::String, file2::String)
    f1 = open(file1, "r")
    f2 = open(file2, "r")
    s1 = read(f1, String)
    s2 = read(f2, String)
    close(f1)
    close(f2)
    # Character-by-character comparison
    for i=1:length(s1)
        if s1[i]!=s2[i]
            println("Character $(i) different: $(s1[i]) $(s2[i])")
        end
    end
    if s1 == s2
        return true
    else
        return false
        println("File 1:")
        @show s1
        println("File 2:")
        @show s2
    end
end

Random.seed!(1234)
sector_names = ["01-05  Animal & Animal Products",
                "06-15  Vegetable Products",
                "16-24  Foodstuffs",
                "25-27  Mineral Products",
                "28-38  Chemicals & Allied Industries",
                "39-40  Plastics / Rubbers",
                "41-43  Raw Hides, Skins, Leather, & Furs",
                "44-49  Wood & Wood Products",
                "50-63  Textiles",
                "64-67  Footwear / Headgear",
                "68-71  Stone / Glass",
                "72-83  Metals",
                "84-85  Machinery / Electrical",
                "86-89  Transportation",
                "90-97  Miscellaneous"]


df_FRA = DataFrame(sector_type = ["Agriculture", "Agriculture", "Light Manufacture", "Heavy Manufacture", "Heavy Manufacture",
    "Heavy Manufacture", "Light Manufacture", "Light Manufacture", "Light Manufacture", "Light Manufacture", "Heavy Manufacture",
    "Heavy Manufacture", "Heavy Manufacture", "Heavy Manufacture", "Other"], 
    varname=Coefplots.latex_escape.(sector_names), 
    b=sort(rand(15)).+3, se = rand(15)./10, dof=10, country="France")

df_CHN = DataFrame(sector_type = ["Agriculture", "Agriculture", "Light Manufacture", "Heavy Manufacture", "Heavy Manufacture",
    "Heavy Manufacture", "Light Manufacture", "Light Manufacture", "Light Manufacture", "Light Manufacture", "Heavy Manufacture",
    "Heavy Manufacture", "Heavy Manufacture", "Heavy Manufacture", "Other"], 
    varname=Coefplots.latex_escape.(sector_names), 
    b=sort(rand(15)).+3, se = rand(15)./10, dof=10, country="China")

gdf_CHN = groupby(df_CHN, [:sector_type])
gdf_FRA = groupby(df_FRA, [:sector_type])

g_CHN = Coefplots.GroupedCoefplot(gdf_CHN; keepconnect=false, vertical=false)
g_FRA = Coefplots.GroupedCoefplot(gdf_FRA; keepconnect=false, vertical=false)

g = Coefplots.GroupedMultiCoefplot(["China" => g_CHN, "France" => g_FRA]; keepconnect=false, 
                                                                          vertical=false, 
                                                                          height=400,
                                                                          show_legend=[false, false, false, true],
                                                                          legend = Coefplots.Legend(at=(0.98,0.02), 
                                                                                                    anchor = Symbol("south east")))
g.xlabel.content = "elasticity"
g.title.content = "My fake plot"
g.note.content = "Note: The classification is only for demonstration purposes, not rigorous."
# Note that SVG creation depends on external libraries that are not distributed with Julia by default
try
    pgfsave("../assets/elasticity.svg", Coefplots.to_picture(g))
catch ex
    @warn "SVG creation failed."
end
pgfsave("../assets/elasticity.png", Coefplots.to_picture(g))
# pgfsave("../assets/elasticity.tex", Coefplots.to_picture(g))
pgfsave("elasticity.tex", Coefplots.to_picture(g))
@test checkfilesarethesame("../assets/elasticity.tex", "elasticity.tex")