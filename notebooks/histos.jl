### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 7adec570-0cf5-11ed-0b5f-110ee1a3d6c4
using Pkg; Pkg.activate("/Users/jj/JuliaProjects/ATools/")

# ╔═╡ c3829892-2f86-4917-90a2-46e39c9ae58d
begin
	using PlutoUI
	using Distributions
	using CSV, DataFrames
	using Statistics
	using StatsBase
	using Plots
end

# ╔═╡ 1db2b93d-9a66-4f71-999f-bc2dae4e5399
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ b183c8be-1604-4d7c-9985-c7fe8e44f8ba
at = ingredients("../src/ATools.jl")

# ╔═╡ 68bd79f2-770d-4fc9-af37-ab9c3ce1b68c
md"""
## Histo1d
"""

# ╔═╡ d8917195-d24e-412d-951c-48ae19480842
md"""
- Generate 50,000 numbers normally distributed
"""

# ╔═╡ 4d34b62c-7c71-47ba-a514-0888e2190383
begin
	dx = Normal(100.0, 5.0);
	data = rand(dx, 50000);
end

# ╔═╡ 884411f3-545d-40bf-98cf-615eb13b3692
begin
	xi = 80.
	xs = 120.
	h1,p1 = at.ATools.hist1d(data, "gaussian data", 100, xi, xs)
	h2,p2 = at.ATools.hist1d(data, "gaussian data normalized", 100, xi, xs, norm=true)
	plot(p1,p2)
end

# ╔═╡ 43ddd4e8-908d-442a-855c-58f30847e0ed
h1

# ╔═╡ Cell order:
# ╠═7adec570-0cf5-11ed-0b5f-110ee1a3d6c4
# ╠═c3829892-2f86-4917-90a2-46e39c9ae58d
# ╠═1db2b93d-9a66-4f71-999f-bc2dae4e5399
# ╠═b183c8be-1604-4d7c-9985-c7fe8e44f8ba
# ╠═68bd79f2-770d-4fc9-af37-ab9c3ce1b68c
# ╠═d8917195-d24e-412d-951c-48ae19480842
# ╠═4d34b62c-7c71-47ba-a514-0888e2190383
# ╠═884411f3-545d-40bf-98cf-615eb13b3692
# ╠═43ddd4e8-908d-442a-855c-58f30847e0ed
