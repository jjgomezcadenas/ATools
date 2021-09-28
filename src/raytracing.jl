using StatsBase
using LinearAlgebra
using Polynomials

"""
	Ray

Represents a ray, characterised by a starting point (p), and a direction (d).
From these, a unit vector, u can be computed.

# Fields
- `p::Vector{Float64}`  : Starting point
- `d::Vector{Float64}`  : Direction vector
- `u::Vector{Float64}`  : Unit vector

"""
struct Ray
    e::Vector{Float64}
    d::Vector{Float64}
    u::Vector{Float64}

    function Ray(e , d)
        new(e, d, unit_vector(d,e))
    end
end


"""
    unit_vector(p0::Vector{Float64}, p1::Vector{Float64})

Return a unit vector in the direction defined by points p0 and p1  
"""
unit_vector(p0::Vector{Float64}, p1::Vector{Float64}) = (p1 - p0) ./ norm(p1 - p0)
    

"""
	propagate_ray(r::Ray)

Return a function that propagates the ray "r" from "e", along "d".

# Fields
- `r::Ray`  : Ray to be propagated
"""
function propagate_ray(r::Ray)
    function xray(t::Real)
        return r.e + t * r.d
    end
    return xray
end


"""
    Represents a Cylinder 
"""
struct Cylinder
    r   :: Float64 
    zmin:: Float64
    zmax:: Float64
end

"""Normal to the cylinder barrel in point p

Uses equation of cylynder: F(x,y,z) = x^2 + y^2 - r^2 = 0
then n = Grad(F)_P /Norm(Grad(F))_P
n = (2x, 2y, 0)/sqrt(4x^2 + 4y^2) = (x,y,0)/r (P)
"""
normal_to_barrel(c::Cylinder, p:: Vector{Float64}) = [p[1], p[2], 0.0] ./c.r

"""
    cylinder_equation(c::Cylinder, p:: Vector{Real}) 

equation of cylynder: F(x,y,z) = x^2 + y^2 - r^2 = 0
"""
cylinder_equation(c::Cylinder, p::Vector{Float64}) = p[1]^2 + p[2]^2 - c.r^2


cylinder_length(c::Cylinder) = abs.(c.zmax - c.zmin)
    
perimeter(c::Cylinder) = 2 * π * c.r

area_barrel(c::Cylinder) = 2 * π * c.r * cylinder_length(c)
    
area_endcap(c::Cylinder) = π * c.r^2
    
area(c::Cylinder) = area_barrel(c) + 2 * area_endcap(c)

volume(c::Cylinder)= area_endcap(c) * cylinder_length(c)


"""Returns True if point in end-caps of cyinder"""
in_endcaps(c:: Cylinder, p::Vector{Float64}) = isapprox(p[3], c.zmin) || isapprox(p[3], c.zmax)
    
    
"""Computes intersection between a ray and a cylinder"""
function propagate(r::Ray, cy::Cylinder)
    
    # intersection roots 
    a = r.d[1]^2 + r.d[2]^2
    b = 2 * (r.e[1] * r.d[1] + r.e[2] * r.d[2])
    c = r.e[1]^2 + r.e[2]^2 - cy.r^2

    # xray(t) propagates ray along t 
    xray = ATools.propagate_ray(r)

    # If no real roots return nothing 
    arg = b^2 - 4*a*c

    # two possible roots 
    t1 = (-b + sqrt(arg))/(2*a)
    t2 = (-b - sqrt(arg))/(2*a)

    # Z position of the two roots 
    z1 = r.e[3] + t1 * r.d[3]
    z2 = r.e[3] + t2 * r.d[3]

    # belong-to-cylinder condition 
    zc1 = cy.zmin < z1 < cy.zmax
    zc2 = cy.zmin < z2 < cy.zmax


    if zc1 == false && zc2 == false
        return nothing
    elseif zc1 == true && zc2 == false
        return t1, xray(t1)
    elseif zc1 == false && zc2 == true
        return t2, xray(t2)
    else
        if t1 > 0 && t2 < 0
            return t1, xray(t1)
        elseif t1 < 0 && t2 > 0
            return t2, xray(t2)
        elseif t1 > 0 && t2 > 0

            if t1 < t2 
                return t1, xray(t1)
            else
                return t2, xray(t2)
            end
        else
            return nothing
        end
    end
end

