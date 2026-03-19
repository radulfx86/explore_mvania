extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var background: ColorRect = $Hero/Camera2D/Background
@onready var camera: Camera2D = $Hero/Camera2D
@export var level_layers: int = 4

@onready var levels: Array[DefaultLevel] = [
	preload("uid://0lvsrqqlppwn").instantiate(),
	preload("uid://dpu4qtwj8awrr").instantiate(),
	preload("uid://8vdangp0j5y").instantiate(),
	preload("uid://dtm1cjwfti2ko").instantiate(),
]

@onready var text_popup = preload("uid://cok7xddd3b6sj")
func _ready() -> void:
	background.size = get_viewport_rect().size/4
	background.position = -background.size/2
	for l in levels:
		l.disable()
		add_child(l)
	enable_level(0)

func enable_level(i: int) -> void:
	tilemap.visible = false
	tilemap.enabled = false
	print("enable level %d" % i)
	for index in range(levels.size()):
		if levels[index]:
			var shall_enable = i == index
			print("changing level %d enable: %s" % [index, shall_enable])
			levels[index].enable(shall_enable)
			#levels[index].visible = shall_enable
			#levels[index].material.set_shader_parameter("reality_color", PlayerProgress.skill_colors[index])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_level"):
		var packed_scene = PackedScene.new()
		packed_scene.pack($TileMapLayer)
		ResourceSaver.save(packed_scene, "res://level_map.tscn")
	elif event.is_action_pressed("switch_level_0"):
		enable_level(0)
		RealityManagement.switch_level(0)
		PlayerProgress.unlock_skill(0)
		PlayerProgress.unlock_skill(1)
		PlayerProgress.unlock_skill(2)
		PlayerProgress.unlock_skill(3)
	elif event.is_action_pressed("switch_level_1"):
		if PlayerProgress.has_skill(PlayerProgress.Skills.RED):
			enable_level(1)
			RealityManagement.switch_level(1)
	elif event.is_action_pressed("switch_level_2"):
		if PlayerProgress.has_skill(PlayerProgress.Skills.GREEN):
			enable_level(2)
			RealityManagement.switch_level(2)
