mutable struct CoefplotOption
    dotsize::Float64
    dotcolor::Color
    linewidth::Float64
    linecolor::Color
    other_dot_options::PGFPlotsX.Options
    other_line_options::PGFPlotsX.Options
    coef_label_angle::Float64
    coef_label_fontsize::Float64
    function CoefplotOption() # get default coefoption
        new(1, get_default_color(:navy), 0.5, get_default_color(:navy), PGFPlotsX.Options(), PGFPlotsX.Options(), 0, 4.5)
    end
end

mutable struct SinglecoefplotOption
    dotsize::Float64
    dotcolor::Color
    linewidth::Float64
    linecolor::Color
    other_dot_options::PGFPlotsX.Options
    other_line_options::PGFPlotsX.Options

    function SinglecoefplotOption() # default option
        new(1, get_default_color(:navy), 0.5, get_default_color(:navy), PGFPlotsX.Options(), PGFPlotsX.Options())
    end
end

get_line_options(option::SinglecoefplotOption) = merge(PGFPlotsX.Options(:"line width"=>option.linewidth),
                                                       color_as_option(option.linecolor),
                                                       option.other_line_options)

get_dot_options(option::SinglecoefplotOption) = merge(color_as_option(option.linecolor),
                                                      option.other_line_options)

function inherit_options_from_coefplot(options::CoefplotOption)
    sub_options = SinglecoefplotOption()
    sub_options.dotsize = options.dotsize
    sub_options.dotcolor = options.dotcolor
    sub_options.linewidth = options.linewidth
    sub_options.linecolor = options.linecolor
    sub_options.other_dot_options = options.other_dot_options
    sub_options.other_line_options = options.other_line_options
end


