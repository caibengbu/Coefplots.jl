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
                       maroon  = Color(RGB(144, 53,  59 )),
                       olive   = Color(RGB(128, 128, 0  )),
                       green   = Color(RGB(0  , 128, 0  )),
                       purple  = Color(RGB(128, 0  , 128)),
                       teal    = Color(RGB(110, 142, 132)),
                       navy    = Color(RGB(26 , 71 , 111)),
                       forest  = Color(RGB(85 , 117, 47 )),
                       dkorg   = Color(RGB(227, 126, 0  )),
                       cranbrry= Color(RGB(193, 5  , 52 )),
                       lavender= Color(RGB(147, 141, 210)),
                       khaki   = Color(RGB(202, 194, 126)),
                       sienna  = Color(RGB(160, 82 , 45 )),
                       emidblue= Color(RGB(123, 146, 168)),
                       emerald = Color(RGB(45 , 109, 102)),
                       brown   = Color(RGB(156, 136, 71 )),
                       erose   = Color(RGB(191, 161, 156)),
                       gold    = Color(RGB(255, 210,   0)),
                       bluegray= Color(RGB(217, 230, 235)))
            
const color_palatte = [:navy, :maroon, :forest, :dkorg, :teal, :cranbrry, :lavender, :khaki,
                       :sienna, :emidblue, :emerald, :brown, :erose, :gold, :bluegray]

changeopacity(color::Color,o::Real) = Color(color.rgb, o)

rbg_as_xcolor(rgb::RGB) = "rgb,255: red, $(rgb.r); green, $(rgb.g); blue, $(rgb.b)"
color_as_xcolor(color::Color) = rbg_as_xcolor(color.rgb)
get_default_color(color_name::Symbol) = color_name in keys(default_color) ? default_color[color_name] : throw(ArgumentError("$(color_name) is not defined."))
colorname_as_xcolor(color_name::Symbol) = color_as_xcolor(get_default_color(color_name))

color_as_option(color::Color) = PGFPlotsX.Options(:color => color_as_xcolor(color), 
                                                  :opacity => color.opacity)
color_as_fill_option(color::Color) = PGFPlotsX.Options(:fill => color_as_xcolor(color), 
                                                       Symbol("fill opacity") => color.opacity)
color_as_draw_option(color::Color) = PGFPlotsX.Options(:draw => color_as_xcolor(color), 
                                                       Symbol("draw opacity") => color.opacity)

color_as_option(color_name::Symbol) = PGFPlotsX.Options(:color => colorname_as_xcolor(color_name), 
                                                        :opacity => get_default_color(color_name).opacity)
color_as_fill_option(color_name::Symbol) = PGFPlotsX.Options(:fill => colorname_as_xcolor(color_name), 
                                                             Symbol("fill opacity") => get_default_color(color_name).opacity)
color_as_draw_option(color_name::Symbol) = PGFPlotsX.Options(:draw => colorname_as_xcolor(color_name), 
                                                             Symbol("draw opacity") => get_default_color(color_name).opacity)