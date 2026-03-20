extends Node2D
class_name DefaultLevel

@export var tiles_map: TileMapLayer
@export var reality_level: int = 0
var mat: ShaderMaterial

func init() -> void:
	mat = ShaderMaterial.new()
	mat.shader = preload("uid://cmk5mkimxhlwx")
	disable()

func enable(value: bool = true) -> void:
	print("enable %s : %s" % [name, value])
	if tiles_map:
		tiles_map.visible = value
		tiles_map.enabled = value
		if tiles_map.material == null:
			tiles_map.material = mat.duplicate()
			tiles_map.material.set_shader_parameter("reality_color", PlayerProgress.skill_colors[reality_level])
			print("initializing tile map of %s with level %d" % [name, reality_level])
	else:
		print("%s does not have a tile map assigned" % name)
	if has_node("Items"):
		for x in $Items.get_children():
			x.visible = value
			print("set %s of %s to %s" %  [x, name, value])
			#x.enabled = value
	if has_node("NPCs"):
		for x in $NPCs.get_children():
			x.set_process(value)
			#x.set_physics_process(value)
			#x.visible = value
			#x.enabled = value

func disable() -> void:
	enable(false)
