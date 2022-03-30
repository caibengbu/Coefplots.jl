struct LineWithEnds
    end1::Tuple
    end2::Tuple
end

function PGFPlotsX.print_tex(io::IO, line::LineWithEnds, options::PGFPlotsX.Options)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot line of the coefplot %%%%%%%%%%")
    print(io, "\\draw")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "(axis cs:$(join(line.end1,","))) -- (axis cs:$(join(line.end2,",")));")
end

struct Dot
    loc::Tuple
end

default_dot_options() = merge(PGFPlotsX.Options(:circle => nothing, :"inner sep" => "0pt",:"minimum size" => "3pt"),color_as_fill_option(:navy))

function PGFPlotsX.print_tex(io::IO, dot::Dot, options::PGFPlotsX.Options)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot dot of the coefplot %%%%%%%%%%")
    print(io, "\\filldraw")
    print(io,"(axis cs:$(join(dot.loc,","))) node")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "{}")
end

function PGFPlotsX.print_tex(io::IO, dot::Dot)
    options = default_dot_options()
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot dot of the coefplot %%%%%%%%%%")
    print(io, "\\filldraw")
    print(io,"(axis cs:$(join(dot.loc,","))) node")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "{}; ")
end

struct AbstractCaption
    caption::String
end

default_xtitle_options() = PGFPlotsX.Options(:name => "xlabel", :anchor => "north", :font => "\\footnotesize", :yshift => "-1em",:at => "(tmp_fig.south)")
default_ytitle_options() = PGFPlotsX.Options(:name => "ylabel", :anchor => "south", :font => "\\footnotesize", :xshift => "-1em", :rotate => 90, :at => "(tmp_fig.west)")
default_note_options() = PGFPlotsX.Options(:name => "note", :anchor => "north west", :font => "{\\fontsize{4.5}{4.5}\\selectfont}", 
                                           :yshift => "-2em", :xshift => "-0.5em", :"text width" => "20em", :at => "(tmp_fig.south west)")
default_title_options() = PGFPlotsX.Options(:name => "title", :anchor => "south", :font => "\\small", :at => "(tmp_fig.north)")

function PGFPlotsX.print_tex(io::IO, caption::AbstractCaption,options::PGFPlotsX.Options)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot caption %%%%%%%%%%")
    print(io, "\\draw node")
    PGFPlotsX.print_options(io, options; newline = false)
    println(io, "{"*caption.caption*"};")
end