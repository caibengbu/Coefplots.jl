using Luxor, Colors
@svg begin
    background(colorant"transparent")
    setopacity(0.85)
    steps = 10
    gap   = 12
    for (n, θ) in enumerate(range(π/4, step=(2π-π/2)/steps, length=steps))
        sethue([Luxor.julia_green,
            Luxor.julia_red,
            Luxor.julia_purple,
            Luxor.julia_blue][mod1(n, 4)])
        sector(Point(-75, 0), 25, 50, θ, θ + 2π/steps - deg2rad(gap), :fill)
    end
     fontsize(45)
     fontface("MyanmarMN-Bold")
     sethue("black")
     text("oefplots.jl", Point(-89, -5) ,halign=:left,valign = :middle)
end 350 100 "logo.svg"