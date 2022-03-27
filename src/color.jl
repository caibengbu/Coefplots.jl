struct RGB
    r::UInt8
    g::UInt8
    b::UInt8

    function RGB(r::Int64,g::Int64,b::Int64)
        @assert 0 <= r <= 255 || 0 <= g <= 255 || 0 <= b <= 255 "wrong input for a color. Float input should be between [0,1], Integer input should be between [0,255]"
        new(r,g,b)
    end
end

struct Color
    rgb::RGB
    opacity::Real
    function Color(rgb::RGB, opacity::Real=1)
        @assert 0 <= opacity <= 1 "wrong choice of opacity"
        new(rgb, opacity)
    end
end

const default_color = (white   = Color(RGB(255, 255, 255)), 
                       black   = Color(RGB(0  , 0  , 0  )), 
                       red     = Color(RGB(255 ,0   ,0  )),
                       lime    = Color(RGB(0  , 255 ,0  )), 
                       blue    = Color(RGB(0  , 0   ,255)), 
                       yellow  = Color(RGB(255, 255, 0  )),
                       magenta = Color(RGB(255 ,0   ,255)), 
                       cyan    = Color(RGB(0   ,255 ,255)), 
                       orange  = Color(RGB(255 ,128, 0  )), 
                       gray    = Color(RGB(128, 128, 128)), 
                       silver  = Color(RGB(191, 191, 191)),
                       pink    = Color(RGB(255, 128, 128)),
                       maroon  = Color(RGB(128, 0  , 0  )),
                       olive   = Color(RGB(128, 128, 0  )),
                       green   = Color(RGB(0  , 128, 0  )),
                       purple  = Color(RGB(128, 0  , 128)),
                       teal    = Color(RGB(0  , 128, 128)),
                       navy    = Color(RGB(26 , 71 , 111)))

rbg_as_xcolor(rgb::RGB) = "rgb,255: red, $(rgb.r); green, $(rgb.g); blue, $(rgb.b)"
color_as_xcolor(color::Color) = rbg_as_xcolor(color.rgb)
get_default_color(color_name::Symbol) = color_name in keys(default_color) ? default_color[color_name] : throw(ArgumentError("$(color_name) is not defined."))
colorname_as_xcolor(color_name::Symbol) = color_as_xcolor(get_default_color(color_name))

color_as_option(color::Color) = PGFPlotsX.Options(:color => color_as_xcolor(color), 
                                                  :opacity => color.opacity)
color_as_fill_option(color::Color) = PGFPlotsX.Options(:"fill" => color_as_xcolor(color), 
                                                       :"fill opacity" => color.opacity)
color_as_draw_option(color::Color) = PGFPlotsX.Options(:color => color_as_xcolor(color), 
                                                       :"draw opacity" => color.opacity)

color_as_option(color_name::Symbol) = PGFPlotsX.Options(:color => colorname_as_xcolor(color_name), 
                                                        :opacity => get_default_color(color_name).opacity)
color_as_fill_option(color_name::Symbol) = PGFPlotsX.Options(:"fill" => colorname_as_xcolor(color_name), 
                                                             :"fill opacity" => get_default_color(color_name).opacity)
color_as_draw_option(color_name::Symbol) = PGFPlotsX.Options(:color => ccolorname_as_xcolor(color_name), 
                                                             :"draw opacity" => get_default_color(color_name).opacity)