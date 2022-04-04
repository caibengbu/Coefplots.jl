using Luxor
@svg begin
    setopacity(0.85)
    steps = 10
    gap   = 12
    for (n, θ) in enumerate(range(π/4, step=(2π-π/2)/steps, length=steps))
        sethue([Luxor.julia_green,
            Luxor.julia_red,
            Luxor.julia_purple,
            Luxor.julia_blue][mod1(n, 4)])
        sector(Point(-100, 0), 50, 100, θ, θ + 2π/steps - deg2rad(gap), :fill)
    end
     fontsize(90)
     fontface("MyanmarMN-Bold")
     sethue("black")
     text("oefplot", Point(-128, -10) ,halign=:left,valign = :middle)
end 420 200 "logo.svg"