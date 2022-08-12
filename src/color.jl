COLOR_LOOP = Iterators.cycle([Colors.JULIA_LOGO_COLORS.blue,
                              Colors.JULIA_LOGO_COLORS.green,
                              Colors.JULIA_LOGO_COLORS.red,
                              Colors.JULIA_LOGO_COLORS.purple])

rbg_as_xcolor(rgb::RGB) = "rgb,255: red, $(Int64(red(rgb)*255)); green, $(Int64(green(rgb)*255)); blue, $(Int64(blue(rgb)*255))"
color_as_xcolor(color::Color) = rbg_as_xcolor(convert(RGB, color))

color_as_option(color::Color) = PGFPlotsX.Options(:color => color_as_xcolor(color), 
                                                  :opacity => Int64(alpha(color)))
color_as_fill_option(color::Color) = PGFPlotsX.Options(:fill => color_as_xcolor(color), 
                                                       Symbol("fill opacity") => Int64(alpha(color)))
color_as_draw_option(color::Color) = PGFPlotsX.Options(:draw => color_as_xcolor(color), 
                                                       Symbol("draw opacity") => Int64(alpha(color)))