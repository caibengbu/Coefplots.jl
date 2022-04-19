struct Null
end

function PGFPlotsX.print_tex(io::IO, n::Null)
end

struct LineWithEnds <: PGFPlotsX.TikzElement
    end1::Tuple
    end2::Tuple
    options::PGFPlotsX.Options
end

function PGFPlotsX.print_tex(io::IO, line::LineWithEnds)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot line of the coefplot %%%%%%%%%%")
    print(io, "\\draw")
    PGFPlotsX.print_options(io, line.options; newline = false)
    println(io, "(axis cs:$(join(line.end1,","))) -- (axis cs:$(join(line.end2,",")));")
end

struct Dot <: PGFPlotsX.TikzElement
    loc::Tuple
    options::PGFPlotsX.Options
end

default_dot_options() = merge(PGFPlotsX.Options(:circle => nothing, :"inner sep" => "0pt",:"minimum size" => "4pt"), color_as_fill_option(:navy))

function PGFPlotsX.print_tex(io::IO, dot::Dot)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot dot of the coefplot %%%%%%%%%%")
    print(io, "\\filldraw")
    print(io,"(axis cs:$(join(dot.loc,","))) node")
    PGFPlotsX.print_options(io, dot.options; newline = false)
    println(io, "{}; ")
end

struct AbstractCaption <: PGFPlotsX.TikzElement
    caption::String
    options::PGFPlotsX.Options
end

default_note_options() = PGFPlotsX.Options(:name => "note", :anchor => "north west", :font => "{\\fontsize{4.5}{4.5}\\selectfont}",
                                           :"text width" => "0.7\\textwidth", :at => "(current axis.outer south west)")

function PGFPlotsX.print_tex(io::IO, caption::AbstractCaption)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot caption %%%%%%%%%%")
    print(io, "\\draw node")
    PGFPlotsX.print_options(io, caption.options; newline = false)
    println(io, "{"*caption.caption*"};")
end

mutable struct Legend <: PGFPlotsX.TikzElement
    l::String
    line_options::PGFPlotsX.Options
    dot_options::PGFPlotsX.Options
end

function PGFPlotsX.print_tex(io::IO, lgd::Legend)
    PGFPlotsX.print_indent(io, "%%%%%%%%% plot legends %%%%%%%%%%")
    print(io, "\\addlegendimage{")
    PGFPlotsX.print_opt(io, lgd.line_options)
    PGFPlotsX.print_opt(io, ", mark = *, mark options = {")
    PGFPlotsX.print_opt(io, lgd.dot_options)
    print(io, "}};")
end

Legend(l::String,representitive_scoptions::SinglecoefplotOption) = Legend(l, get_line_options(representitive_scoptions),
                                                                          merge(get_dot_options(representitive_scoptions), 
                                                                          color_as_draw_option(changeopacity(representitive_scoptions.dotcolor,0)))) # need to set draw opacity = 0

mutable struct Plotable <: PGFPlotsX.TikzElement
    options::PGFPlotsX.Options
    note::Union{AbstractCaption,Null}
    contents::Vector{T} where T
    function Plotable(options::PGFPlotsX.Options, note::Union{AbstractCaption,Null}, contents...)
        new(options, note, collect(contents))
    end
end

function PGFPlotsX.print_tex(io::IO, p::Plotable)
    print(io, "\\begin{axis}")
    PGFPlotsX.print_options(io, p.options)
    PGFPlotsX.print_indent(io) do io
        for elt in p.contents
            PGFPlotsX.print_tex(io, elt)
        end
    end
    println(io, "\\end{axis}")
    PGFPlotsX.print_tex(io, p.note)
end




