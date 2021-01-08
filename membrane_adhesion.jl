### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 9402df7c-4c3d-11eb-0f04-670058576045
using Plots, PlutoUI, Optim

# ╔═╡ 99fb7628-502a-11eb-1d23-7d3a143cd5d3
gr();

# ╔═╡ 032c42f2-5103-11eb-0dce-e7ec59924648
html"<button onclick='present()'>present</button>"

# ╔═╡ 0bb068de-512d-11eb-14e3-8f3de757910d
struct TwoColumn{A, B}
	left::A
	right::B
end

# ╔═╡ 827fbc3a-512d-11eb-209e-cd74ddc17bae
function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
	write(io,
		"""
		<div style="display: flex;">
			<div style="flex: 50%;">
		""")
	show(io, mime, tc.left)
	write(io,
		"""
			</div>
			<div style="flex: 50%;">
		""")
	show(io, mime, tc.right)
	write(io,
		"""
			</div>
		</div>
	""")
end

# ╔═╡ 6382a73e-5102-11eb-1cfb-f192df63435a
md"""
# Adhesion of membranes with competing specific and generic interactions
**Andreas Kröpelin, January 11, 2021**

based on the paper by T. R. Weikl *et. al.*

Seminar *Systems Biology of Immunology*
"""

# ╔═╡ 6118fcf2-5103-11eb-0adc-1749ac4663a3
md"""
## Overview
- Physical model of membranes
- Linear sticker potential
"""

# ╔═╡ 74f5d956-5104-11eb-09d8-3f6c54c0349c
md"""
## Physical model of membranes

Membranes are not arbitrarily flexible (only down to ≈ 6 nm) → **discrete grid**
"""

# ╔═╡ 6bdd5fd8-5109-11eb-0f0e-45ecd18f4ee4
wireframe(zeros(7, 7), zlim= (-5,5), showaxis=false, size=(600,300))

# ╔═╡ 337711c4-511e-11eb-3d2a-e31539b21208
md"""
Each grid point can **move** freely **along verical axis**:
"""

# ╔═╡ 4c75d21e-511e-11eb-0dcc-c789e4668f3f
let
	membr = zeros(7, 7)
	a = @animate for t in 0:.1:2π
		membr[4, 4] = 3sin(t)
		plot([4, 4], [4, 4], [-5, 5], legend=:none, lw=3, s=:dot)
		wireframe!(membr, zlim=(-5,5), showaxis=false, size=(600,300))
	end
	gif(a, fps = 10)
end

# ╔═╡ b2c22d78-511f-11eb-1fa6-091be862c054
md"""
Some grid points have **sticker proteins attached**:
"""

# ╔═╡ d28451b8-511f-11eb-1357-9b9bcfd4a484
let
	wireframe(zeros(7, 7), zlim= (-5,5), showaxis=false, size=(600,300))
	scatter3d!([1, 4, 2, 6], [5, 7, 3, 2], [0, 0, 0, 0], label="stickers")
end

# ╔═╡ 0c9067de-5120-11eb-2237-713e8e71e70c
md"""
↪ grid point ``i`` has **two degrees of freedom**:
- height ``h_i \in \mathbb{R}_{\geq 0}``
- sticker attached? ``n_i \in \{0, 1\}``
"""

# ╔═╡ 09defe78-512b-11eb-2580-fb7151aab310
md"""
## Interactions
Assume that system is governed by **three interactions**:
- elastic membrane bending
- generic potential
- specific adhesion potential
"""

# ╔═╡ 93ae20e2-5136-11eb-0583-77ab9914dff9
md"""
## Refresher: harmonic and linear potentials
"""

# ╔═╡ c62d8b2a-5136-11eb-04e9-61f66857db36
TwoColumn(
	md"""
	### Harmonic potential
	Spring, pendulum, hole through earth
	
	**force:** ``\text{const} \cdot x``
	
	**potential:** ``\frac12 \text{const} \cdot x^2``
	""",
	let
		a = @animate for t in 0:.1:2π
			plot([-1, 1], [0, 0], s=:dash, lw=3)
			plot!([0], [sin(t)], xlim=(-1,1), ylim=(-1.5,1.5), showaxis=false, gridalpha=0.3, leg=:none, ms=10, shape=:circle)			
		end
		gif(a, fps=20)
	end
)

# ╔═╡ 54ec3a66-513a-11eb-2cba-23e172fc04f9
TwoColumn(
	md"""
	### Linear potential
	Free fall, accelerating rocket
	
	**force:** ``\text{const}``
	
	**potential:** ``\text{const} \cdot x``
	""",
	let
		a = @animate for t in 1:-.05:0
			plot([0], [t], xlim=(-1,1), ylim=(0,1), ms=10, shape=:circle, showaxis=false, leg=:none, c=2, gridalpha=0.3)
		end
		gif(a, fps=15)
	end
)

# ╔═╡ 5dc4c808-512c-11eb-2014-09beef01c5ff
md"""
## Elastic membrane bending

"""

# ╔═╡ 8fcea4c2-5131-11eb-2485-33adf0944eea
TwoColumn(
	md"""
	Membrane counteracts curvature → Laplacian
	```math
	Δ h = \frac{∂^2 h}{∂ x^2} + \frac{∂^2 h}{∂ y^2}
	```
	("how far below environment?")
	
	Bended membrane experiences **force** ``\kappa ⋅ Δ h``
	
	and stores **energy** ``\frac{\kappa}{2} (\Delta h)^2``.
	""",
	let
		membr = zeros(7, 7)
		membr[3, 4] = 1.
		membr[2,2] = -2.
		wireframe(membr, zlim=(-5,5), showaxis=false, size=(400,300))
		plot!([4, 4], [3, 3], [-1, -3], lw=3, c=:darkblue, leg=:none)
		plot!([4], [3], [-3], shape=:dtriangle, c=:darkblue)
		plot!([2, 2], [2, 2], [.2, 2.2], lw=3, c=:darkblue, leg=:none)
		plot!([2], [2], [2.2], shape=:utriangle, c=:darkblue)
	end
)

# ╔═╡ 354a363c-4c3e-11eb-2d7d-398e30d0d89c
@bind α Slider(1:.1:3)

# ╔═╡ dda5740e-4c3e-11eb-09f9-93185afaefc1
α

# ╔═╡ a3d46864-4c40-11eb-10b1-fd5ce77cde34
@bind ϵ Slider(-.1:.01:.1)

# ╔═╡ b4d5c3ec-4c40-11eb-178f-d7b83eb832fc
ϵ

# ╔═╡ 2718742a-4c3e-11eb-2fe6-a7576ffbd2cd
μ = -α^2/2 + ϵ

# ╔═╡ e9dc97a8-4c3d-11eb-38cf-77ff3d88cbbf
V_ef(h) = .5 * h^2 - log(1 + exp(μ - α * h))

# ╔═╡ 1566ae32-4c3f-11eb-0584-35a6a6a66ac9
h(z) = z - α/2

# ╔═╡ 4aa320de-4c3e-11eb-1430-19b130c88fe8
plot(-2:.1:2, V_ef.(h.((-2:.1:2))))

# ╔═╡ e7aaff68-4d09-11eb-3dbd-21317062a338
optimize(V_ef ∘ h, -2, 2) |> Optim.minimizer

# ╔═╡ acc59366-5024-11eb-02c2-8bcec276b8a5
struct MembranePatch
	height::Float64
	velocity::Float64
end

# ╔═╡ 9f3bb8dc-4d1c-11eb-2088-d127849cb358
function Δ(A, pos)
	neighbours = (
		CartesianIndex(0, 1),
		CartesianIndex(0, -1),
		CartesianIndex(1, 0),
		CartesianIndex(-1, 0)
	)
	
	sum(
		A[pos + n].height - A[pos].height
		for n in neighbours if pos + n ∈ CartesianIndices(A)
	)
end

# ╔═╡ 283a8c06-4d17-11eb-06bf-7daf19a17658
function time_step!(membr_new, membr, stickers; dt, κ, λ, α, l₀)
	for pos in CartesianIndices(membr)
		curv = Δ(membr, pos)
		l = membr[pos].height
		n = pos ∈ stickers
		
		acc = κ * curv
		acc += -λ * (l - l₀)
		acc += -n * α
		
		membr_new[pos] = MembranePatch(
			membr[pos].height + dt * membr[pos].velocity,
			membr[pos].velocity + dt * acc
		)
	end
end

# ╔═╡ 3de19c2a-5019-11eb-0d2e-cf782fccd088
function random_membrane(rows, cols)
	# [exp(-.01((x - rows/2)^2 + (y - cols/2)^2)) for x in 1:rows, y in 1:cols]
	[
		MembranePatch(2.7 + .1sin(.4((x-rows/2)^2 + (y-cols/2)^2)), 0)
		# MembranePatch(2.0, 0.0)
		for x in 1:rows, y in 1:cols
	]
end

# ╔═╡ 0a8d4148-4d22-11eb-0c71-67f46d380c8c
let
	dt = .1
	stickers_x = rand(1:7, 5)
	stickers_y = rand(1:7, 5)
	stickers = zip(stickers_x, stickers_y) .|> CartesianIndex
	membr = random_membrane(7, 7)
	membr_new = similar(membr)
	
	animation = @animate for t in 0:dt:10
		time_step!(membr_new, membr, stickers, dt=dt, κ = 0.1, λ = 0.05, α = 0.3, l₀ = 3.)
		membr, membr_new = membr_new, membr
		
		wireframe([mp.height for mp in membr], zlim=(0,10), title="time: $t")
		scatter3d!(stickers_y, stickers_x, [membr[pos].height for pos in stickers], label="stickers")
	end
	
	gif(animation, fps = 20)
end

# ╔═╡ Cell order:
# ╟─9402df7c-4c3d-11eb-0f04-670058576045
# ╟─99fb7628-502a-11eb-1d23-7d3a143cd5d3
# ╟─032c42f2-5103-11eb-0dce-e7ec59924648
# ╟─0bb068de-512d-11eb-14e3-8f3de757910d
# ╟─827fbc3a-512d-11eb-209e-cd74ddc17bae
# ╟─6382a73e-5102-11eb-1cfb-f192df63435a
# ╟─6118fcf2-5103-11eb-0adc-1749ac4663a3
# ╟─74f5d956-5104-11eb-09d8-3f6c54c0349c
# ╟─6bdd5fd8-5109-11eb-0f0e-45ecd18f4ee4
# ╟─337711c4-511e-11eb-3d2a-e31539b21208
# ╟─4c75d21e-511e-11eb-0dcc-c789e4668f3f
# ╟─b2c22d78-511f-11eb-1fa6-091be862c054
# ╟─d28451b8-511f-11eb-1357-9b9bcfd4a484
# ╟─0c9067de-5120-11eb-2237-713e8e71e70c
# ╟─09defe78-512b-11eb-2580-fb7151aab310
# ╟─93ae20e2-5136-11eb-0583-77ab9914dff9
# ╟─c62d8b2a-5136-11eb-04e9-61f66857db36
# ╟─54ec3a66-513a-11eb-2cba-23e172fc04f9
# ╟─5dc4c808-512c-11eb-2014-09beef01c5ff
# ╟─8fcea4c2-5131-11eb-2485-33adf0944eea
# ╟─354a363c-4c3e-11eb-2d7d-398e30d0d89c
# ╠═dda5740e-4c3e-11eb-09f9-93185afaefc1
# ╟─a3d46864-4c40-11eb-10b1-fd5ce77cde34
# ╠═b4d5c3ec-4c40-11eb-178f-d7b83eb832fc
# ╠═2718742a-4c3e-11eb-2fe6-a7576ffbd2cd
# ╠═e9dc97a8-4c3d-11eb-38cf-77ff3d88cbbf
# ╠═1566ae32-4c3f-11eb-0584-35a6a6a66ac9
# ╠═4aa320de-4c3e-11eb-1430-19b130c88fe8
# ╠═e7aaff68-4d09-11eb-3dbd-21317062a338
# ╠═acc59366-5024-11eb-02c2-8bcec276b8a5
# ╟─283a8c06-4d17-11eb-06bf-7daf19a17658
# ╠═0a8d4148-4d22-11eb-0c71-67f46d380c8c
# ╟─9f3bb8dc-4d1c-11eb-2088-d127849cb358
# ╠═3de19c2a-5019-11eb-0d2e-cf782fccd088
