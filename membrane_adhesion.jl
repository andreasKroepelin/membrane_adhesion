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
using Plots, PlutoUI

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
## Introduction
Attraction to other membranes/surfaces mediated by adhesion molecules → observe **phase separation** into domains with small and large distance.

###### Can we theoretically explain, why?

#### Roadmap
1. A physical model of membranes
1. How membranes interact
1. Statistical physics, transforming the system
1. Identifying stable states under different conditions
"""

# ╔═╡ 74f5d956-5104-11eb-09d8-3f6c54c0349c
md"""
## Physical model of "biomimetic" membranes

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
Some grid points have irreversible **sticker molecules attached**:
"""

# ╔═╡ d28451b8-511f-11eb-1357-9b9bcfd4a484
let
	wireframe(zeros(7, 7), zlim= (-5,5), showaxis=false, size=(600,300))
	scatter3d!([1, 4, 2, 6], [5, 7, 3, 2], [0, 0, 0, 0], label="stickers")
end

# ╔═╡ 0c9067de-5120-11eb-2237-713e8e71e70c
md"""
↪ grid point ``i`` has **two degrees of freedom**:
- height ``h_i \in \mathbb{R}``
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

# ╔═╡ b1c888e0-51f1-11eb-3539-d9029b5aadca
md"""
> Potential ``V(x)`` ⟶ Force ``F(x) = -\frac{\mathrm{d}V(x)}{\mathrm{d}x}``
"""

# ╔═╡ c62d8b2a-5136-11eb-04e9-61f66857db36
TwoColumn(
	md"""
	### Harmonic potential
	Spring, pendulum, hole through earth
	
	**force:** ``-\text{const} \cdot x``
	
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
	
	**force:** ``-\text{const}``
	
	**potential:** ``\text{const} \cdot x``
	""",
	let
		a = @animate for t in 1:-.02:0
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

# ╔═╡ 1afe5352-51b5-11eb-02c0-0b85f5ece696
md"""
## Generic interaction potential
"""

# ╔═╡ 5f9c70f2-51e9-11eb-2aaa-a9f77c2bf308
TwoColumn(
	md"""
	Membrane is close to surface/other membrane → *Lennard-Jones potential*
	
	Local approximation as **harmonic potential**: ``V_\text{g}(h) = \frac12 h^2``
	
	(``h = 0`` at minimum of potential)
	""",
	let
		σ = .4
		m = 2^(1/6) * σ
		plot(.39:.005:.9, r -> (σ/r)^12 - (σ/r)^6, label="Lennard-Jones", lw=2, size=(400,300), ticks=false, xguide="distance", yguide="potential")
		plot!((m-.05):.005:(m+.0525), r -> 40 * (r - m)^2 - 1/4, label="harmonic approximation", lw=2)
	end
)

# ╔═╡ 33935bb8-51f0-11eb-3cba-41bbf9fda673
md"""
## Specific interaction potential

Extended sticker molecules *constantly pull down*.

**Force** ``-\alpha`` and **potential** ``V_\text{s}(h) = \alpha \cdot h``

Stickers also have internal **chemical potential** ``\mu``

Only relevant for grid points ``i`` with sticker: ``n_i \cdot (\alpha h_i - \mu)``
"""

# ╔═╡ 884fb50a-529c-11eb-0b1d-077dc6aac82f
md"""
## Putting it all together

Total energy of the system (*Hamiltionian*):
```math
\mathcal{H}(h,n) = \sum_i \frac{\kappa}{2} ( \Delta h_i )^2 + \frac12 h_i^2 + n_i \cdot (\alpha h_i - \mu)
```
"""

# ╔═╡ 9746768c-529e-11eb-1872-2f8ea1befbb4
md"### Dynamic illustration"

# ╔═╡ 13a98e26-529f-11eb-34ee-991ba1a30a68
md"""
## Partition functions

Statistical physics describes systems **as a whole**, summarising all particles

Important tool: **partition function ``\mathcal{Z}`` → sum of all state probabilities**

###### Probability of a state
Boltzmann says: probability proportional to ``\exp(-\frac{1}{T} E)`` for state with energy ``E``

⟶ sum up all those terms for every state
"""

# ╔═╡ 8dc766a4-52ba-11eb-2980-cb039c493081
md"""
## Partition function for our membrane system
###### states:
- each ``h_i`` can have some value → one integral for each grid point
- each ``n_i`` can be 0 or 1 → sum over ``\{0,1\}`` for each grid point

###### partition function for 3 grid points:
```math
\mathcal{Z} = \int \int \int \left( \sum_{n_1 \in \{0,1\}} \sum_{n_2 \in \{0,1\}} \sum_{n_3 \in \{0,1\}} \exp \left( -\frac{1}{T} \mathcal{H}(h, n) \right) \right) \mathrm{d} h_1\, \mathrm{d} h_2\, \mathrm{d} h_3
```
"""

# ╔═╡ 3d545e7c-52a4-11eb-3cfe-ff3123a63d1d
md"""
## Can we get that any simpler, please?

> Consider only sums over ``n_i``:
> ```math
> \sum_{n_1 \in \{0,1\}} \sum_{n_2 \in \{0,1\}} \sum_{n_3 \in \{0,1\}} \exp \left( -\frac{1}{T} \mathcal{H}(h, n) \right)
> ```
> Substitute Hamiltonian:
> ```math
> \sum_{n_1 \in \{0,1\}} \sum_{n_2 \in \{0,1\}} \sum_{n_3 \in \{0,1\}} \exp \left( -\frac{1}{T} \sum_i \underbrace{ \frac{\kappa}{2} ( \Delta h_i )^2 + \frac12 h_i^2 }_{\text{independent of } n} + n_i \cdot (\alpha h_i - \mu) \right)
> ```
> ```math
> = \text{independent} \cdot \sum_{n_1 \in \{0,1\}} \sum_{n_2 \in \{0,1\}} \sum_{n_3 \in \{0,1\}} \exp \left( -\frac{1}{T} \sum_i n_i \cdot (\alpha h_i - \mu) \right)
> ```
> Focus on sum over specific potentials:
> ```math
> \sum_{n_1 \in \{0,1\}} \sum_{n_2 \in \{0,1\}} \sum_{n_3 \in \{0,1\}} \exp \left( -\frac{1}{T}  \left ( \begin{array}{c} n_1 \cdot (\alpha h_1 - \mu) + \\ n_2 \cdot (\alpha h_2 - \mu) + \\ n_3 \cdot (\alpha h_3 - \mu) \end{array} \right) \right)
> ```
> ```math
> = \sum_{n_1 \in \{0,1\}} \sum_{n_2 \in \{0,1\}} \sum_{n_3 \in \{0,1\}} \exp(\ldots n_1 \ldots) \exp(\ldots n_2 \ldots) \exp(\ldots n_3 \ldots)
> ```
> Consider this identity:
> ```math
> \sum_i \sum_j \sum_k f(i) \cdot f(j) \cdot f(k)
> ```
> ```math
> = \sum_i f(i) \left( \sum_j f(j) \left( \sum_k f(k) \right) \right)
> ```
> ```math
> = \left( \sum_k f(k) \right) \left( \sum_j f(j)  \right) \left( \sum_i f(i) \right)
> ```
> So, we obtain:
> ```math
> = \left( \sum_{n_1 \in \{0,1\}} \exp(\ldots n_1 \ldots) \right) \left( \sum_{n_2 \in \{0,1\}} \exp(\ldots n_2 \ldots) \right) \left( \sum_{n_3 \in \{0,1\}} \exp(\ldots n_3 \ldots) \right)
> ```
> Factor ``i`` evaluates to:
> ```math
> \sum_{n_i \in \{0,1\}} \exp \left( -\frac{1}{T} n_i \cdot (\alpha h_i - \mu) \right)
> ```
> ```math
> = 1 \quad + \quad \exp \left( -\frac{1}{T} \cdot (\alpha h_i - \mu) \right)
> ```
> So, the triple-sum over the specific potentials becomes:
> ```math
> \prod_i \left( 1 + \exp \left( -\frac{1}{T} \cdot (\alpha h_i - \mu) \right) \right)
> ```
> ```math
> = \exp \left( -\frac{1}{T} \cdot (-T) \ln \left( \prod_i \left( 1 + \exp \left( -\frac{1}{T} \cdot (\alpha h_i - \mu) \right) \right) \right) \right)
> ```
> ```math
> = \exp \left( -\frac{1}{T} \cdot \sum_i -T \cdot \ln \left( 1 + \exp \left( -\frac{1}{T} \cdot (\alpha h_i - \mu) \right) \right) \right)
> ```
> With 
> ```math
> V^\ast(h) = -T \cdot \ln \left( 1 + \exp \left( -\frac{1}{T} \cdot (\alpha h - \mu) \right) \right)
> ```
> we obtain:
> ```math
> = \exp \left( -\frac{1}{T} \cdot \sum_i V^\ast(h_i) \right)
> ```
> So, the whole sum becomes:
> ```math
> \exp \left( -\frac{1}{T} \cdot \sum_i \frac{\kappa}{2} ( \Delta h_i )^2 + \frac12 h_i^2 + V^\ast(h_i) \right)
> ```
> **which is independent of the ``n_i``!**
"""

# ╔═╡ 991d34fe-52b8-11eb-3e69-71c14752fa93
md"""
## Outcome of summation over ``n``

```math
\mathcal{Z} = \int \int \int \left( \sum_{n_1 \in \{0,1\}} \sum_{n_2 \in \{0,1\}} \sum_{n_3 \in \{0,1\}} \exp \left( -\frac{1}{T} \mathcal{H}(h, n) \right) \right) \mathrm{d} h_1\, \mathrm{d} h_2\, \mathrm{d} h_3
```
becomes
```math
\int \int \int \left( \exp \left( -\frac{1}{T} \mathcal{H}^\ast(h) \right) \right) \mathrm{d} h_1\, \mathrm{d} h_2\, \mathrm{d} h_3
```

##### From a statistical physics point-of-view, the membrane with stickers is equivalent to a *homogenous* membrane with specific potential ``V^\ast``.
"""

# ╔═╡ 07cfb42c-52bd-11eb-3cc4-f1b62fde1267
md"""
## Stable state of rigid membranes
Assume that membrane is very rigid (``\kappa`` large) → no bending → can neglect elastic term

Potential for one grid point is effectively:
```math
V_\text{ef}(h) = \frac12 h^2 - \ln(1 + \exp(\mu - \alpha h))
```

Each grid point takes state where ``V_\text{ef}`` is at global minimum.
"""

# ╔═╡ bcfa8132-52dc-11eb-031e-8bff734f18b1
sl_α = @bind α Slider(1:.05:3, default=1.5);

# ╔═╡ 41c6409a-52dd-11eb-146f-3dcd349a59d7
sl_α

# ╔═╡ eade94b4-52dc-11eb-1d44-2f336d6cc0c5
md"α = $α"

# ╔═╡ d53b14fa-52dc-11eb-383c-d96e79de0ba1
μ = -α^2 / 2

# ╔═╡ 6e048840-533e-11eb-194a-6d3fe473e373
md" ##### ⇒ Bifurcation"

# ╔═╡ eb5456ac-52cd-11eb-183c-6d108568cfeb
md"""
## Sticker concentration

We ignored their positions but can still identify their number!

Each sticker contributes its chemical potential ``\mu`` to effective potential ``V_\text{ef}`` → number of stickers determines relationship between these quantities.

```math
\text{number of stickers} = -\frac{\partial V_\text{ef}}{\partial \mu} = \frac{\exp(\mu - \alpha h)}{1 + \exp(\mu - \alpha h)}
```
"""

# ╔═╡ a5636ab2-52de-11eb-03f8-c7d9be959f23
sl_α

# ╔═╡ b4bd1140-52de-11eb-108b-ff7679ea201c
md"α = $α"

# ╔═╡ 20727094-52e2-11eb-04e4-796e8b8aac73
md"""
##### ⇒ Phases separation

1. sticker-rich, strong adhesion, small distance
1. sticker-poor, weak adhesion, high distance
"""

# ╔═╡ 79b48202-5353-11eb-109a-b5d8e1fdb8c2
md"""
## Stable states of flexible membranes

Fluctuating membranes make **crossing potential barriers easier**.

Lower ``\kappa``

→ higher flexibility

→ need **higher potential barrier for phase separation**

→ need **higher ``\alpha``**

#### How to specify when phase separation occurs?

Know state probabilities (partition function!)

→ **Monte Carlo** sampling for fixed ``\kappa`` and ``\alpha``

→ analyse distribution of ``h_i``
"""

# ╔═╡ f26f191e-5367-11eb-208d-173b3c47b125
md"""
## Summary

- modelled membrane as **discrete grid** with two degrees of freedom for each grid point: ``h_i`` and ``n_i``
- assumed that total energy is composed of **elastic, generic, and sepcific potential**
- could show that **ignoring sticker positions** ``n_i`` is equivalent
- found **bifurcation** behaviour for stable states → **phase separation**
- contemplated the **influence of membrane fluctuations**
"""

# ╔═╡ 0ec1d616-536a-11eb-00a8-d1e93d12e199
md"""
## Context and Final remarks
- modelling approach quite broad, can be used with other potentials
- results contrast *entropy-based* models showing that weaker adhesion and more energy increase phase separation
- method integrates physical modelling, mathematical analysis, and stochastical simulation
"""

# ╔═╡ 95e1a562-5360-11eb-19d4-a72985938bd7
md"## "

# ╔═╡ c2c900fa-5360-11eb-3597-e9db443f74c1
md"## "

# ╔═╡ fc3bb076-52c5-11eb-3786-696ee9c7eb42
function eval_V_ef(α, μ)
	hs = (-2:.1:2) .- α/2
	V(h) = h^2/2 - log(1 + exp(μ - α * h))
	vs = V.(hs)
	min_v = minimum(vs)
	min_hs = filter(h -> V(h) ≈ min_v, hs)
	(hs, vs, min_v, min_hs)
end

# ╔═╡ 3535ec6c-52ca-11eb-08a8-ab2c019b1e16
let
	(hs, vs, min_v, min_hs) = eval_V_ef(α, μ)
	plot(hs, vs, size=(600,300), leg=:none, xguide="h", yguide="effective potential")
	scatter!(min_hs, fill(min_v, length(min_hs)))
end

# ╔═╡ b711d3a8-52df-11eb-1d8e-fd2938d23044
function eval_sticker_conc(α, μ)
	(_, _, _, min_hs) = eval_V_ef(α, μ)
	N(h) = exp(μ - α * h) / (1 + exp(μ - α * h))
	N.(min_hs)
end

# ╔═╡ 467f380a-52e0-11eb-12d3-4f7305483ae2
begin
	conc_los = [minimum(eval_sticker_conc(α, -α^2/2)) for α in 1:.05:3]
	conc_his = [maximum(eval_sticker_conc(α, -α^2/2)) for α in 1:.05:3]
end;

# ╔═╡ badd3f52-52d2-11eb-2940-559721d6bad7
let
	ns = eval_sticker_conc(α, μ)
	
	plot(1:.05:3, conc_los, s=:dash, c=1)
	plot!(1:.05:3, conc_his, s=:dash, c=1)
	scatter!(fill(α, length(ns)), ns, leg=:none, xlim=(1,3), ylim=(0,1), yguide="sticker concentration", xguide="α", size=(600,300))
end

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
function time_step!(membr_new, membr, stickers; dt, κ, α)
	for pos in CartesianIndices(membr)
		curv = Δ(membr, pos)
		h = membr[pos].height
		n = pos ∈ stickers
		
		acc = κ * curv
		acc += -.2 * h
		acc += -n * α
		
		membr_new[pos] = MembranePatch(
			membr[pos].height + dt * membr[pos].velocity,
			membr[pos].velocity + dt * acc
		)
	end
end

# ╔═╡ 3de19c2a-5019-11eb-0d2e-cf782fccd088
function random_membrane(rows, cols)
	[
		MembranePatch(-.3 + .2sin(.4((x-rows/2)^2 + (y-cols/2)^2)), 0)
		# MembranePatch(0.0, 0.0)
		for x in 1:rows, y in 1:cols
	]
end

# ╔═╡ 0a8d4148-4d22-11eb-0c71-67f46d380c8c
function simulate_membrane(; κ, α)
	dt = .2
	stickers_x = rand(1:7, 3)
	stickers_y = rand(1:7, 3)
	stickers = zip(stickers_x, stickers_y) .|> CartesianIndex
	membr = random_membrane(7, 7)
	membr_new = similar(membr)
	
	animation = @animate for t in 0:dt:20
		time_step!(membr_new, membr, stickers, dt=dt, κ=κ, α=α)
		membr, membr_new = membr_new, membr
		
		wireframe([mp.height for mp in membr], zlim=(-5,5), title="time: $t")
		scatter3d!(stickers_y, stickers_x, [membr[pos].height for pos in stickers], label="stickers")
	end
	
	gif(animation, fps = 20)
end

# ╔═╡ 67769042-529c-11eb-39df-4bf23071224f
simulate_membrane(κ = .05, α = .1)

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
# ╟─b1c888e0-51f1-11eb-3539-d9029b5aadca
# ╟─c62d8b2a-5136-11eb-04e9-61f66857db36
# ╟─54ec3a66-513a-11eb-2cba-23e172fc04f9
# ╟─5dc4c808-512c-11eb-2014-09beef01c5ff
# ╟─8fcea4c2-5131-11eb-2485-33adf0944eea
# ╟─1afe5352-51b5-11eb-02c0-0b85f5ece696
# ╟─5f9c70f2-51e9-11eb-2aaa-a9f77c2bf308
# ╟─33935bb8-51f0-11eb-3cba-41bbf9fda673
# ╟─884fb50a-529c-11eb-0b1d-077dc6aac82f
# ╟─9746768c-529e-11eb-1872-2f8ea1befbb4
# ╠═67769042-529c-11eb-39df-4bf23071224f
# ╟─13a98e26-529f-11eb-34ee-991ba1a30a68
# ╟─8dc766a4-52ba-11eb-2980-cb039c493081
# ╟─3d545e7c-52a4-11eb-3cfe-ff3123a63d1d
# ╟─991d34fe-52b8-11eb-3e69-71c14752fa93
# ╟─07cfb42c-52bd-11eb-3cc4-f1b62fde1267
# ╟─3535ec6c-52ca-11eb-08a8-ab2c019b1e16
# ╟─41c6409a-52dd-11eb-146f-3dcd349a59d7
# ╟─eade94b4-52dc-11eb-1d44-2f336d6cc0c5
# ╠═d53b14fa-52dc-11eb-383c-d96e79de0ba1
# ╟─bcfa8132-52dc-11eb-031e-8bff734f18b1
# ╟─6e048840-533e-11eb-194a-6d3fe473e373
# ╟─eb5456ac-52cd-11eb-183c-6d108568cfeb
# ╟─a5636ab2-52de-11eb-03f8-c7d9be959f23
# ╟─b4bd1140-52de-11eb-108b-ff7679ea201c
# ╟─badd3f52-52d2-11eb-2940-559721d6bad7
# ╟─20727094-52e2-11eb-04e4-796e8b8aac73
# ╟─79b48202-5353-11eb-109a-b5d8e1fdb8c2
# ╟─f26f191e-5367-11eb-208d-173b3c47b125
# ╟─0ec1d616-536a-11eb-00a8-d1e93d12e199
# ╟─95e1a562-5360-11eb-19d4-a72985938bd7
# ╟─c2c900fa-5360-11eb-3597-e9db443f74c1
# ╟─b711d3a8-52df-11eb-1d8e-fd2938d23044
# ╟─fc3bb076-52c5-11eb-3786-696ee9c7eb42
# ╟─467f380a-52e0-11eb-12d3-4f7305483ae2
# ╟─acc59366-5024-11eb-02c2-8bcec276b8a5
# ╟─0a8d4148-4d22-11eb-0c71-67f46d380c8c
# ╟─9f3bb8dc-4d1c-11eb-2088-d127849cb358
# ╟─283a8c06-4d17-11eb-06bf-7daf19a17658
# ╟─3de19c2a-5019-11eb-0d2e-cf782fccd088
