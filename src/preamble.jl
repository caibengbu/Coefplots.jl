function gen_default_preamble()
    preamble = []
    push!(preamble, "% Default preamble")
    push!(preamble, "\\usepackage{pgfplots}")
    push!(preamble, "\\pgfplotsset{compat=newest}")
    push!(preamble, "\\usepackage{lmodern}")
    push!(preamble, "\\usepackage[T1]{fontenc}")
end

function newcommand_singlecoefplot(dotcolor="black", barcolor="black", linewidth="0.2mm")
    newcommand = []
    push!(newcommand, "\\newcommand{\\singlecoefplot}[4]{")  
    push!(newcommand, "\\filldraw[$dotcolor] (axis cs:#1,#2) circle (1pt) ;") 
    push!(newcommand, "\\draw[$barcolor, line width=$linewidth] (axis cs:#1,#2) -- (axis cs:#1,#4); ") 
    push!(newcommand, "\\draw[$barcolor, line width=$linewidth] (axis cs:#1,#2) -- (axis cs:#1,#3); }")
end

push!(PGFPlotsX.CUSTOM_PREAMBLE, gen_default_preamble()...,newcommand_singlecoefplot()...)