### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 9f804990-4492-11ec-12a4-f12a95ec63dc
using CairoMakie

# ╔═╡ 107045c2-0b9b-407a-bdfb-bb212bf247d1
using Makie.Colors

# ╔═╡ b65b78d8-4f95-45e7-8ec6-793dcc9c91de
using PlutoUI

# ╔═╡ e5138ac8-b485-4557-a495-f3eee162c805
TableOfContents()

# ╔═╡ bd33fa12-e50c-4346-8cfd-991cf33793bd
α = Node(π/5)

# ╔═╡ 0be8ca36-d361-46e5-8759-c3276c800f30
duration = 3#s

# ╔═╡ e64fc85b-167f-4b97-9260-84a78b36e088
framerate = 30 #Hz

# ╔═╡ 9a8d55dc-d897-4856-a1a7-3e7411beb7c2
fiber_length = 5

# ╔═╡ a149bc4b-0098-41b9-ad98-11b64e8ac55a
fiber_width = Node(1)

# ╔═╡ 152e7cb0-d3e7-4067-b5f0-53afe48370c9
number_of_rays = @lift(ceil(fiber_length / $fiber_width * tan($α)))

# ╔═╡ 033c2f07-f9b7-4974-8ddd-e49103d10c27
md"# Rays"

# ╔═╡ bdd9cb39-abaa-42c9-a489-fc869c71f132
time_rays = Node(0.0)

# ╔═╡ 099f1943-a5fa-4f03-9e1c-01ae40295077
arrow_size = @lift([
	if (i-1)/$number_of_rays < $time_rays <= i/$number_of_rays
		30
	else
		0
	end
	for i ∈ 1:$number_of_rays
])

# ╔═╡ 32412b64-2c49-497d-bd32-e8a9f8aa88d5
limited_expanser(a,b,t) = if a < t < b
	(t-a)/(b-a) 
elseif t >= b
	1.0
else
	0.0
end

# ╔═╡ 791f9bce-20c1-4493-b419-d08f94dc5469
rays_u = @lift([limited_expanser((i-1)/$number_of_rays,i/$number_of_rays,$time_rays)*$fiber_width/tan($α) for i ∈ 1:$number_of_rays])

# ╔═╡ af9d4a5c-f972-4099-bb12-5ee84d4c0618
rays_v = @lift([limited_expanser((i-1)/$number_of_rays,i/$number_of_rays,$time_rays)*2*(i%2 - 0.5)*$fiber_width for i ∈ 1:$number_of_rays])

# ╔═╡ e056fcfb-6aa0-4102-8e77-9938fb28c46e
rays_x = @lift([(i-1)*$fiber_width/tan($α) for i ∈ 1:$number_of_rays])

# ╔═╡ 361b629b-9e60-4615-b5ad-0c615d42178c
rays_y = @lift([if i%2 == 0 0.5 else -0.5 end for i ∈ 1:$number_of_rays])

# ╔═╡ 32a6fd60-8253-41c1-8f35-a7d60716a06c
color_core = RGB(159/255, 214/255, 244/255)

# ╔═╡ 7a461bc1-a5b7-470a-bafd-a286d5487d34
color_cladding = RGB(143/255, 176/255, 193/255)

# ╔═╡ c9975c15-8537-401e-8dbf-cb90999e968a
fig_rays, ax_rays, plot_rays = let
	f = Figure(resolution=(800, 300))
	ax = Axis(
		f[1,1],
		aspect=DataAspect()
	)
	hidedecorations!(ax)
	hidespines!(ax)
	actual_length = @lift($number_of_rays*$fiber_width/tan($α))
	poly!(@lift(Point2f[(0, -0.75), ($actual_length, -0.75), ($actual_length, 0.75), (0, 0.75)]), color = color_cladding)
	poly!(@lift(Point2f[(0, -0.5), ($actual_length, -0.5), ($actual_length, 0.5), (0, 0.5)]), color = color_core)

	text!([L"n_1", L"n_2"], 
		position = @lift([Point($fiber_width/tan($α), -0.15), Point($fiber_width/tan($α), 0.80)]), 
		align = (:left, :top),
    	#offset = (-20, 0),
		color = :black,
		textsize=28
	)

	p = arrows!(
		ax,
		rays_x, rays_y, rays_u, rays_v,
		linewidth=6,
		arrowsize=arrow_size,
		color=:red
	)

	text!(["CC-BY-SA Hugo Levy-Falk 2021"], 
		position = @lift([Point($actual_length/2, -0.51)]), 
		align = (:center, :top),
    	#offset = (-20, 0),
		color = :black,
		textsize=24
	)
	
	f, ax, p
end;

# ╔═╡ 3d9551a2-a92b-45e3-91d5-14a5698535de
md"""
Testing this

t = $(@bind t_rays_test PlutoUI.Slider(0:0.1:1, show_value=true))
"""

# ╔═╡ f6757511-2087-48ab-b483-f23a91aa30ee
begin
	time_rays[] = t_rays_test
	save("frame_rays.png", fig_rays)
	frame_file_rays = "frame_rays.png"
	fig_rays
end

# ╔═╡ 5c77c569-8bea-4f1f-b5df-ccca15fc74a2
DownloadButton(read(frame_file_rays), basename(frame_file_rays))

# ╔═╡ cf4339a7-0f18-4f3d-bee5-ec0cf02edaf3
md"And now animate this:"

# ╔═╡ 5a550224-4aa8-4fe8-860c-2c11c0e37b54
animation_rays_file = record(fig_rays, "rays_animation.mp4", range(0, 2, length=2*framerate*duration); framerate = framerate) do t
	time_rays[] = t
end;

# ╔═╡ 003cf426-40c0-426e-9581-4a22c615a2d5
LocalResource(animation_rays_file)

# ╔═╡ 04b1601f-0329-4928-b5fe-644d9adab2d7
DownloadButton(read(animation_rays_file), basename(animation_rays_file))

# ╔═╡ 5f0bc6fa-a2ea-44f5-a68b-b700a9c089e1
md"# Plane waves"

# ╔═╡ 79b2a804-df49-40e2-a6cd-70ee7572e1bf
duration_plane_waves = 24#s

# ╔═╡ e3f05e07-bc97-4af7-b5c5-21d03449d5e4
plane_wave_field(x,y,kx,ky,ω,t) = real(exp(im*(ω*t-kx*x-ky*y)))

# ╔═╡ 907ab47c-336a-4900-bfc2-679dcd566527
actual_length = @lift($number_of_rays*$fiber_width/tan($α))

# ╔═╡ 15a6b921-f454-4b07-997c-5b77dbbbf73c
xs = @lift(range(0,$actual_length, step=$fiber_width/100))

# ╔═╡ f57676f9-7ace-4c2b-a05c-f3f6afaa97c5
ys = @lift(range(-$fiber_width/2,$fiber_width/2, step=$fiber_width/100))

# ╔═╡ 8b3f3b79-1514-46e0-b012-8d61e12faa51
X = @lift(reshape(repeat($xs, length($ys)), :, length($ys)))

# ╔═╡ 2489d8c0-62f9-4cbf-939a-5ef7ffaf2971
Y = @lift(reshape(repeat($ys, length($xs)), :, length($xs))')

# ╔═╡ 420493eb-361e-41d3-9493-bd6222e4c893
time_plane_waves = Node(0.0)

# ╔═╡ 5b776856-41ea-49f9-86b6-0bcf5b7d28c0
kx = @lift(cos($α)*2π/(0.2*$fiber_width))

# ╔═╡ 94afa29a-6021-425d-b205-e1d1d7caba81
ky = @lift(sin($α)*2π/(0.2*$fiber_width))

# ╔═╡ 158e5f5b-1cca-4140-8de4-f450a8d3d168
ω = Node(2π*framerate/2)

# ╔═╡ a20eb5e1-f20f-4653-8b80-1b1ec415b603
field_plane_wave = @lift(@. limited_expanser(0,0.25,$time_plane_waves)*real(exp(im*($ω*$time_plane_waves-$kx*$X-$ky*$Y))) + limited_expanser(0.5,0.75,$time_plane_waves)*real(exp(im*($ω*$time_plane_waves-$kx*$X+$ky*$Y))))

# ╔═╡ 37ea9553-ad75-4942-a56d-be1590cdcf61
plane_u = @lift([
	if i%2 == 1
		limited_expanser(0,0.25,$time_plane_waves)
	else
		limited_expanser(0.5,0.75,$time_plane_waves)
	end*$fiber_width/tan($α) for i ∈ 1:$number_of_rays
])

# ╔═╡ f956583d-25e4-4b1a-8643-ecac85e3e195
plane_v = @lift([
	if i%2 == 1
		limited_expanser(0,0.25,$time_plane_waves)
	else
		limited_expanser(0.5,0.75,$time_plane_waves)
	end*2*(i%2 - 0.5)*$fiber_width for i ∈ 1:$number_of_rays
])

# ╔═╡ 4fcc9624-538a-4b99-9f16-dbe8dfbc91fd
arrow_size_plane = @lift([
	if (i%2 == 1 && 0<$time_plane_waves<=0.5) || (i%2 == 0 && 0.5<$time_plane_waves<1)
		30
	else
		0
	end
	for i ∈ 1:$number_of_rays
])

# ╔═╡ 726d64e3-5486-43af-91c5-7a79927b6cf9
fig_plane, ax_plane, plot_plane = let
	f = Figure(resolution=(800,300))
	ax = Axis(
		f[1,1],
		aspect=DataAspect()
	)
	hidedecorations!(ax)
	hidespines!(ax)
	actual_length = @lift($number_of_rays*$fiber_width/tan($α))
	poly!(@lift(Point2f[(0, -0.75), ($actual_length, -0.75), ($actual_length, 0.75), (0, 0.75)]), color = color_cladding)
	poly!(@lift(Point2f[(0, -0.5), ($actual_length, -0.5), ($actual_length, 0.5), (0, 0.5)]), color = color_core)

	p = heatmap!(ax, xs, ys,field_plane_wave, colormap=:PuBu_9)

	text!([L"n_1", L"n_2"], 
		position = @lift([Point($fiber_width/tan($α), -0.15), Point($fiber_width/tan($α), 0.80)]), 
		align = (:left, :top),
    	#offset = (-20, 0),
		color = [:black, :black],
		textsize=28
	)
	
	arrows!(
		ax,
		rays_x, rays_y, plane_u, plane_v,
		linewidth=6,
		arrowsize=arrow_size_plane,
		color = :red
	)

	text!(["CC-BY-SA Hugo Levy-Falk 2021"], 
		position = @lift([Point($actual_length/2, -0.52)]), 
		align = (:center, :top),
    	#offset = (-20, 0),
		color = :black,
		textsize=24
	)
	f, ax, p
end;

# ╔═╡ 38efbafb-c0c4-4f8f-9adc-c22de517fe91
md"""
Testing this

t = $(@bind t_plane_test PlutoUI.Slider(0:0.1:1, show_value=true))
"""

# ╔═╡ 48d73e57-e095-4a92-8f7a-2d0721f536a9
begin
	time_plane_waves[] = t_plane_test
	save("frame_plane.png", fig_plane)
	frame_file_plane = "frame_plane.png"
	fig_plane
end

# ╔═╡ ffc30278-f0b0-4533-96a0-2f3cb662062d
DownloadButton(read(frame_file_plane), basename(frame_file_plane))

# ╔═╡ 7b6803eb-33dc-4007-9985-11e18f1787fa
animation_plane_file = record(fig_plane, "plane_animation.mp4", range(0, 2, length=framerate*duration_plane_waves); framerate = framerate) do t
	time_plane_waves[] = t
end;

# ╔═╡ 93bc6413-3226-4c86-8c54-df6916958c08
LocalResource(animation_plane_file)

# ╔═╡ 8942572b-ec19-45b9-b5d9-4398522a4f96
DownloadButton(read(animation_plane_file), basename(animation_plane_file))

# ╔═╡ e6936913-cb31-434d-920c-6ddc9a5be47c


# ╔═╡ 47db145d-d32d-43cd-9efa-8e8b699d35b3
md"# Multiple Rays"

# ╔═╡ 4997d1d7-5cd8-47de-a150-14e9999987f9
rays_u_m = @lift([limited_expanser((i-1)/$number_of_rays,i/$number_of_rays,$time_rays)*$fiber_width/tan($α * 1.5) for i ∈ 1:$number_of_rays])

# ╔═╡ 2f39a3f6-dc15-4eee-8072-10a380ec0aa6
rays_v_m = @lift([limited_expanser((i-1)/$number_of_rays,i/$number_of_rays,$time_rays)*2*(i%2 - 0.5)*$fiber_width for i ∈ 1:$number_of_rays])

# ╔═╡ 6f587ac9-7754-4912-a80b-807dfdf3ba4c
rays_x_m = @lift([(i-1)*$fiber_width/tan($α * 1.5) for i ∈ 1:$number_of_rays])

# ╔═╡ 9ab762a8-31c9-4c3a-9989-c50ce63a729e
rays_y_m = @lift([if i%2 == 0 0.5 else -0.5 end for i ∈ 1:$number_of_rays])

# ╔═╡ 5750ee6a-acec-4c75-8bcd-735a301bc685
fig_m_rays, ax_m_rays, plot_m_rays = let
	f = Figure(resolution=(800, 300))
	ax = Axis(
		f[1,1],
		aspect=DataAspect()
	)
	hidedecorations!(ax)
	hidespines!(ax)
	actual_length = @lift($number_of_rays*$fiber_width/tan($α))
	poly!(@lift(Point2f[(0, -0.75), ($actual_length, -0.75), ($actual_length, 0.75), (0, 0.75)]), color = color_cladding)
	poly!(@lift(Point2f[(0, -0.5), ($actual_length, -0.5), ($actual_length, 0.5), (0, 0.5)]), color = color_core)

	p = arrows!(
		ax,
		rays_x, rays_y, rays_u, rays_v,
		linewidth=6,
		arrowsize=arrow_size,
		color=:red
	)
	arrows!(
		ax,
		rays_x_m, rays_y_m, rays_u_m, rays_v_m,
		linewidth=6,
		arrowsize=arrow_size,
		color=:green
	)

	text!([L"n_1", L"n_2"], 
		position = @lift([Point($fiber_width/tan($α), -0.15), Point($fiber_width/tan($α), 0.80)]), 
		align = (:left, :top),
    	#offset = (-20, 0),
		color = :black,
		textsize=28
	)

	text!(["CC-BY-SA Hugo Levy-Falk 2021"], 
		position = @lift([Point($actual_length/2, -0.51)]), 
		align = (:center, :top),
    	#offset = (-20, 0),
		color = :black,
		textsize=24
	)
	
	f, ax, p
end;

# ╔═╡ 08b00c9a-b021-4bc5-a474-c3d95837b634
md"""
Testing this

t = $(@bind t_rays_test2 PlutoUI.Slider(0:0.1:1, show_value=true))
"""

# ╔═╡ 4e7ced91-1f90-47f1-a542-683b3b4a7c9b
begin
	time_rays[] = t_rays_test2
	save("frame_rays2.png", fig_m_rays)
	frame_file_rays2 = "frame_rays2.png"
	fig_m_rays
end

# ╔═╡ 8a45be15-e408-4196-a0ae-802fc5b5d966
DownloadButton(read(frame_file_rays2), basename(frame_file_rays2))

# ╔═╡ 7af1d50f-3f8f-4213-afa5-8c7619e95c2a
md"And now animate this:"

# ╔═╡ 9b9638a3-ec06-4b40-9697-628ad57b1859
animation_rays_file2 = record(fig_m_rays, "rays_animation2.mp4", range(0, 2, length=2*framerate*duration); framerate = framerate) do t
	time_rays[] = t
end;

# ╔═╡ 616740e9-3a09-41fb-b1f0-1905e2863056
LocalResource(animation_rays_file2)

# ╔═╡ 25977036-b518-4033-897c-964b08ea372e
DownloadButton(read(animation_rays_file2), basename(animation_rays_file2))

# ╔═╡ bcbaf623-af72-4e34-93e8-ac9e0a848bb1
md"# Pulses broadening"

# ╔═╡ 556a54c8-a9fb-43a4-87c5-0949d4771c21
time_pulses = Node(0.0)

# ╔═╡ 328315f6-7d1f-46b5-8cd1-9e7ccad035f5
number_of_pulses = Node(3)

# ╔═╡ c318fe3a-27fc-4387-aead-ad9309446267
xs_pulses = @lift(0:0.01:($number_of_pulses+1))

# ╔═╡ 0f7add3a-b070-442d-a97f-00424ffd6ca3
σmin = Node(0.1)

# ╔═╡ b1ec8411-1cef-4cec-be0e-1e81a6bfe0de
σmax = Node(0.7)

# ╔═╡ c0ccb7cb-9fe5-4fe4-8dc1-c6016ee2e51e
σ = @lift((1-$time_pulses)*$σmin + $σmax*$time_pulses)

# ╔═╡ 96eeb683-e040-418c-ad30-a10224f842ca
pulses_train = @lift(sum([@.(1/( $σ*√(2π))*exp(-($xs_pulses-i)^2/(2*$σ^2))) for i ∈ 1:$number_of_pulses]))

# ╔═╡ 6ed2821d-bc84-4ffb-b5df-eb2b1cdab670
fig_pulses, ax_pulses, plot_pulses = let
	f = Figure(resolution=(800,300))
	ax = Axis(
		f[1,1],
		#aspect=DataAspect()
		title=@lift("t = $(round($time_pulses, digits = 1))"),
		titlesize=24,
		xlabel="Z",
		ylabel="Intensité"
	)
	p = lines!(ax, xs_pulses, pulses_train, linewidth=4)

	f, ax, p
end;

# ╔═╡ 8957cdeb-93ae-491a-bd49-21f8b11a8104
md"""
Testing this

t = $(@bind t_pulses_test PlutoUI.Slider(0:0.1:1, show_value=true))
"""

# ╔═╡ 6b4e9e6d-51bb-42fd-be99-ba779b2c3897
begin
	time_pulses[] = t_pulses_test
	save("frame_pulses.png", fig_pulses)
	frame_file_pulses = "frame_pulses.png"
	fig_pulses
end

# ╔═╡ 8a9cf8bd-e6ff-4aaf-8f8c-78debd24d1a3
DownloadButton(read(frame_file_pulses), basename(frame_file_pulses))

# ╔═╡ d633047f-18b9-422a-89bf-7dc9838862cd
animation_pulses_file = record(fig_pulses, "pulses_animation.mp4", range(0, 2, length=2*framerate*duration); framerate = framerate) do t
	time_pulses[] = t
end;

# ╔═╡ 460b57ca-37b3-4dcf-b876-44f4de87e718
LocalResource(animation_pulses_file)

# ╔═╡ 01fde3f8-ecc1-4a88-9c19-a8021116b4f3
DownloadButton(read(animation_pulses_file), basename(animation_pulses_file))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CairoMakie = "~0.6.6"
Makie = "~0.15.3"
PlutoUI = "~0.7.19"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0bc60e3006ad95b4bb7497698dd7c6d649b9bc06"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "e527b258413e0c6d4f66ade574744c94edef81f8"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.40"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "StaticArrays"]
git-tree-sha1 = "774ff1cce3ae930af3948c120c15eeb96c886c33"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.6.6"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "45efb332df2e86f2cb2e992239b6267d97c9e0b6"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.7"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "794daf62dce7df839b8ed446fc59c68db4b5182f"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.3.3"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "cce8159f0fee1281335a04bbf876572e46c921ba"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.29"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "9aad812fb7c4c038da7cab5a069f502e6e3ae030"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.1"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2db648b6712831ecb333eae76dbfd1c156ca13bb"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.2"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "StaticArrays"]
git-tree-sha1 = "19d0f1e234c13bbfd75258e55c52aa1d876115f5"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.2"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "70938436e2720e6cb8a7f2ca9f1bbdbf40d7f5d0"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.6.4"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "a2951c93684551467265e0e32b577914f69532be"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.9"

[[Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "56b0b7772676c499430dc8eb15cfab120c05a150"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.15.3"

[[MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "7bcc8323fb37523a6a51ade2234eee27a11114c8"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.1.3"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Match]]
git-tree-sha1 = "5cf525d97caf86d29307150fcba763a64eaa9cbe"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.1.0"

[[MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "70e733037bbf02d691e78f95171a1fa08cdc6332"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.2.1"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "c8b8775b2f242c80ea85c83714c64ecfa3c53355"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.3"

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "6d105d40e30b635cfed9d52ec29cf456e27d38f8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.12"

[[Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "646eed6f6a5d8df6708f15ea7e02a7a2c4fe4800"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.10"

[[Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9bc1871464b12ed19297fbc56c4fb4ba84988b0d"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.47.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "e071adf21e165ea0d904b595544a8e514c8bb42c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.19"

[[PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SIMD]]
git-tree-sha1 = "9ba33637b24341aba594a2783a502760aa0bff04"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.3.1"

[[ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "e7bc80dc93f50857a5d1e3c8121495852f407e6a"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "385ab64e64e79f0cd7cfcf897169b91ebbb2d6c8"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.13"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "c342ae2abf4902d65a0b0bf59b28506a6e17078a"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.5.2"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[isoband_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "a1ac99674715995a536bbce674b068ec1b7d893d"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.2+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╟─e5138ac8-b485-4557-a495-f3eee162c805
# ╠═9f804990-4492-11ec-12a4-f12a95ec63dc
# ╠═107045c2-0b9b-407a-bdfb-bb212bf247d1
# ╠═b65b78d8-4f95-45e7-8ec6-793dcc9c91de
# ╠═bd33fa12-e50c-4346-8cfd-991cf33793bd
# ╠═0be8ca36-d361-46e5-8759-c3276c800f30
# ╠═e64fc85b-167f-4b97-9260-84a78b36e088
# ╠═9a8d55dc-d897-4856-a1a7-3e7411beb7c2
# ╠═a149bc4b-0098-41b9-ad98-11b64e8ac55a
# ╠═152e7cb0-d3e7-4067-b5f0-53afe48370c9
# ╟─033c2f07-f9b7-4974-8ddd-e49103d10c27
# ╠═bdd9cb39-abaa-42c9-a489-fc869c71f132
# ╠═099f1943-a5fa-4f03-9e1c-01ae40295077
# ╠═32412b64-2c49-497d-bd32-e8a9f8aa88d5
# ╠═791f9bce-20c1-4493-b419-d08f94dc5469
# ╠═af9d4a5c-f972-4099-bb12-5ee84d4c0618
# ╠═e056fcfb-6aa0-4102-8e77-9938fb28c46e
# ╠═361b629b-9e60-4615-b5ad-0c615d42178c
# ╟─32a6fd60-8253-41c1-8f35-a7d60716a06c
# ╟─7a461bc1-a5b7-470a-bafd-a286d5487d34
# ╠═c9975c15-8537-401e-8dbf-cb90999e968a
# ╟─3d9551a2-a92b-45e3-91d5-14a5698535de
# ╟─f6757511-2087-48ab-b483-f23a91aa30ee
# ╟─5c77c569-8bea-4f1f-b5df-ccca15fc74a2
# ╟─cf4339a7-0f18-4f3d-bee5-ec0cf02edaf3
# ╠═5a550224-4aa8-4fe8-860c-2c11c0e37b54
# ╟─003cf426-40c0-426e-9581-4a22c615a2d5
# ╟─04b1601f-0329-4928-b5fe-644d9adab2d7
# ╟─5f0bc6fa-a2ea-44f5-a68b-b700a9c089e1
# ╠═79b2a804-df49-40e2-a6cd-70ee7572e1bf
# ╠═e3f05e07-bc97-4af7-b5c5-21d03449d5e4
# ╠═907ab47c-336a-4900-bfc2-679dcd566527
# ╠═15a6b921-f454-4b07-997c-5b77dbbbf73c
# ╠═f57676f9-7ace-4c2b-a05c-f3f6afaa97c5
# ╠═8b3f3b79-1514-46e0-b012-8d61e12faa51
# ╠═2489d8c0-62f9-4cbf-939a-5ef7ffaf2971
# ╠═420493eb-361e-41d3-9493-bd6222e4c893
# ╠═5b776856-41ea-49f9-86b6-0bcf5b7d28c0
# ╠═94afa29a-6021-425d-b205-e1d1d7caba81
# ╠═158e5f5b-1cca-4140-8de4-f450a8d3d168
# ╠═a20eb5e1-f20f-4653-8b80-1b1ec415b603
# ╠═37ea9553-ad75-4942-a56d-be1590cdcf61
# ╠═f956583d-25e4-4b1a-8643-ecac85e3e195
# ╠═4fcc9624-538a-4b99-9f16-dbe8dfbc91fd
# ╠═726d64e3-5486-43af-91c5-7a79927b6cf9
# ╟─38efbafb-c0c4-4f8f-9adc-c22de517fe91
# ╟─48d73e57-e095-4a92-8f7a-2d0721f536a9
# ╟─ffc30278-f0b0-4533-96a0-2f3cb662062d
# ╠═7b6803eb-33dc-4007-9985-11e18f1787fa
# ╟─93bc6413-3226-4c86-8c54-df6916958c08
# ╟─8942572b-ec19-45b9-b5d9-4398522a4f96
# ╠═e6936913-cb31-434d-920c-6ddc9a5be47c
# ╠═47db145d-d32d-43cd-9efa-8e8b699d35b3
# ╠═4997d1d7-5cd8-47de-a150-14e9999987f9
# ╠═2f39a3f6-dc15-4eee-8072-10a380ec0aa6
# ╠═6f587ac9-7754-4912-a80b-807dfdf3ba4c
# ╠═9ab762a8-31c9-4c3a-9989-c50ce63a729e
# ╠═5750ee6a-acec-4c75-8bcd-735a301bc685
# ╟─08b00c9a-b021-4bc5-a474-c3d95837b634
# ╠═4e7ced91-1f90-47f1-a542-683b3b4a7c9b
# ╠═8a45be15-e408-4196-a0ae-802fc5b5d966
# ╟─7af1d50f-3f8f-4213-afa5-8c7619e95c2a
# ╠═9b9638a3-ec06-4b40-9697-628ad57b1859
# ╠═616740e9-3a09-41fb-b1f0-1905e2863056
# ╟─25977036-b518-4033-897c-964b08ea372e
# ╟─bcbaf623-af72-4e34-93e8-ac9e0a848bb1
# ╠═556a54c8-a9fb-43a4-87c5-0949d4771c21
# ╠═328315f6-7d1f-46b5-8cd1-9e7ccad035f5
# ╠═c318fe3a-27fc-4387-aead-ad9309446267
# ╠═0f7add3a-b070-442d-a97f-00424ffd6ca3
# ╠═b1ec8411-1cef-4cec-be0e-1e81a6bfe0de
# ╠═c0ccb7cb-9fe5-4fe4-8dc1-c6016ee2e51e
# ╠═96eeb683-e040-418c-ad30-a10224f842ca
# ╠═6ed2821d-bc84-4ffb-b5df-eb2b1cdab670
# ╟─8957cdeb-93ae-491a-bd49-21f8b11a8104
# ╟─6b4e9e6d-51bb-42fd-be99-ba779b2c3897
# ╟─8a9cf8bd-e6ff-4aaf-8f8c-78debd24d1a3
# ╠═d633047f-18b9-422a-89bf-7dc9838862cd
# ╟─460b57ca-37b3-4dcf-b876-44f4de87e718
# ╟─01fde3f8-ecc1-4a88-9c19-a8021116b4f3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
