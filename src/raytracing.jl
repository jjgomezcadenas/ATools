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
    p::Vector{Float64}
    d::Vector{Float64}
    u::Vector{Float64}

    function Ray(p , d)
        new(p, d, unit_vector(d,p))
    end
end


"""
    unit_vector(p0::Vector{Real}, p1::Vector{Real})

Return a unit vector in the direction defined by points p0 and p1  
"""
unit_vector(p0::Vector{Float64}, p1::Vector{Float64}) = (p1 - p0) ./ norm(p1 - p0)
    

"""
	propagate_ray(r::Ray)

Return a function that propagates the ray "r" from "p", along "e".

# Fields
- `r::Ray`  : Ray to be propagated
"""
function propagate_ray(r::Ray)
    function xray(t::Real)
        return r.p + t * r.d
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
    
    
"""Computes intersection roots between a ray and a cylinder"""
function intersection_roots(r::Ray, c::Cylinder)
    
    a = r.d[1]^2 + r.d[2]^2
    b = 2 * (r.p[1] * r.d[1] + r.p[2] * r.d[2])
    c = r.p[1]^2 + r.p[2]^2 - c.r^2

    roots(Polynomial([a, b, -c]))
end


# def ray_intersection_with_cylinder_end_caps(r: Ray, c: Cylinder, t: float)->np.array:
#     """Intersection between a ray and the end-cups of a cylinder"""
#     p = r.ray(t)
#     if p[2] > c.zmax:
#         t = (c.zmax - r.e[2])/r.d[2]
#     else:
#         t = (c.zmin - r.e[2])/r.d[2]

#     return t, r.ray(t)


# def ray_intersection_with_cylinder(r: Ray, c:Cylinder)->Tuple[float,np.array]:
#     """Intersection between a ray and a cylinder"""
#     t = cylinder_intersection_roots(r, c)
#     P = r.ray(t)
#     z = P[2]
#     if z < c.zmin or z > c.zmax:
#         t, P = ray_intersection_with_cylinder_end_caps(r, c, t)
#     return t, P


