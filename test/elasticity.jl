include("../src/Coefplots.jl")
using .Coefplots
# using Coefplots
using GLM
using DataFrames, CSV
using Random
using PGFPlotsX

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


df_FRA = DataFrame(sector_type = ["Agriculture", "Agriculture", "Light", "Heavy", "Heavy",
    "Heavy", "Light", "Light", "Light", "Light", "Heavy",
    "Heavy", "Heavy", "Heavy", "Other"], 
    varname=Coefplots.latex_escape.(sector_names), 
    b=sort(rand(15)).+3, se = rand(15)./10, dof=10, country="France")

df_CHN = DataFrame(sector_type = ["Agriculture", "Agriculture", "Light", "Heavy", "Heavy",
    "Heavy", "Light", "Light", "Light", "Light", "Heavy",
    "Heavy", "Heavy", "Heavy", "Other"], 
    varname=Coefplots.latex_escape.(sector_names), 
    b=sort(rand(15)).+3, se = rand(15)./10, dof=10, country="China")

gdf_CHN = groupby(df_CHN, [:sector_type])
gdf_FRA = groupby(df_FRA, [:sector_type])

g_CHN = Coefplots.GroupedCoefplot(gdf_CHN; keepconnect=false, vertical=false)
g_FRA = Coefplots.GroupedCoefplot(gdf_FRA; keepconnect=false, vertical=false)

data = ["China" => g_CHN, "France" => g_FRA]

g = Coefplots.GroupedMultiCoefplot(data; keepconnect=false, vertical=false, height=400)
g.xlabel.content = "elasticity"
g.title.content = "My fake plot"
g.note.content = "Note: Heavy = Heavy manufacture, Light = Light manufacture. The classification is only for demonstration purposes, not rigorous."
pgfsave("../assets/elasticity.svg", Coefplots.to_picture(g))