extends Control

var using_anti_noise := true

func _ready():
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	
	_on_viewport_size_changed()
	
	$ViewportAntiNoise/TextureShader.texture = $ViewportSource.get_texture()
	$ResultTexture.texture = $ViewportAntiNoise.get_texture()
	
	$VBoxContainer/LabelEnableShader.text = "Now: %s" % "enabled" if using_anti_noise else "disabled"

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		using_anti_noise = !using_anti_noise
		var m : ShaderMaterial = $ViewportAntiNoise/TextureShader.material
		m.set_shader_param("enable", using_anti_noise)
		$VBoxContainer/LabelEnableShader.text = "Now: %s" % ("enabled" if using_anti_noise else "disabled")

func _on_viewport_size_changed():
	$ViewportAntiNoise.size = get_viewport().size
	$ViewportAntiNoise/TextureShader.rect_size = get_viewport().size
	$ViewportSource.size = get_viewport().size
