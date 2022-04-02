mutable struct CoefplotOption
    xticklabel_angle::Float64
    xticklabel_size::Float64
    yticklabel_angle::Float64
    yticklabel_size::Float64
    other_coefplot_options::PGFPlotsX.Options
end

mutable struct SinglecoefplotOption
    dotsize::Float64
    dotcolor::Color
    linewidth::Float64
    linecolor::Color
    other_dot_options::PGFPlotsX.Options
    other_line_options::PGFPlotsX.Options
end

default_singlecoefplot_options() = SinglecoefplotOption(4, get_default_color(:navy), 0.5, get_default_color(:navy), PGFPlotsX.Options(), PGFPlotsX.Options())

default_coefplot_options() = CoefplotOption(0, 5, 0, 5, PGFPlotsX.Options())

get_line_options(option::SinglecoefplotOption) = merge(option.other_line_options,
                                                       color_as_option(option.linecolor),
                                                       PGFPlotsX.Options(Symbol("line width") => option.linewidth))

get_dot_options(option::SinglecoefplotOption) = merge(option.other_dot_options,
                                                      color_as_fill_option(option.dotcolor),
                                                      PGFPlotsX.Options(:circle => nothing, # TODO consider make this flexible 
                                                                        Symbol("inner sep") => 0,
                                                                        Symbol("minimum size") => option.dotsize))

get_coefplot_options(option::CoefplotOption) = merge(option.other_coefplot_options,
                                                     PGFPlotsX.Options(Symbol("xticklabel style")=> "font=\\fontsize{$(option.xticklabel_size)}{$(option.xticklabel_size)}\\selectfont, rotate=$(option.xticklabel_angle)"),
                                                     PGFPlotsX.Options(Symbol("yticklabel style")=> "font=\\fontsize{$(option.yticklabel_size)}{$(option.yticklabel_size)}\\selectfont, rotate=$(option.yticklabel_angle)"))

Base.:(==)(o1::PGFPlotsX.Options,o2::PGFPlotsX.Options) = (o1.dict == o2.dict) && (o1.print_empty == o2.print_empty)
function Base.:(==)(so1::SinglecoefplotOption,so2::SinglecoefplotOption)
    for fieldname in fieldnames(typeof(so1))
        if getfield(so1,fieldname) == getfield(so2,fieldname)
            continue
        else
            return false
        end
    end
    return true
end
function all_equal(v::Vector{SinglecoefplotOption})
    for i in 1:(length(v)-1)
        if v[i] == v[i+1]
            continue
        else
            return false
        end
    end
    return true
end
