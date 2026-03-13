extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer

@export var level_layers: int = 4

@onready var levels: Array[TileMapLayer] = [
	preload("res://levels/level_0.tscn").instantiate(),
	preload("res://levels/level_1.tscn").instantiate(),
	preload("res://levels/level_2.tscn").instantiate(),
	preload("res://levels/level_3.tscn").instantiate(),
]

@onready var text_popup = preload("uid://cok7xddd3b6sj")

func _ready() -> void:
	var c: int = 0
	for l in levels:
		if l == null:
			load_level(c)
			c += 1
			continue
		l.visible = false
		l.enabled = false
		l.material.set_shader_parameter("reality_color", PlayerProgress.skill_colors[c])
		add_child(l)
		c += 1
		pass
	#enable_level(0)
	load_level(0)
	tilemap.material.set_shader_parameter("reality_color", PlayerProgress.skill_colors[0])
	pass

func enable_level(i: int) -> void:
	tilemap.visible = false
	tilemap.enabled = false
	for index in range(levels.size()):
		if levels[index]:
			var shall_enable = i == index
			levels[index].visible = shall_enable
			levels[index].enabled = shall_enable

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_level"):
		var packed_scene = PackedScene.new()
		packed_scene.pack($TileMapLayer)
		ResourceSaver.save(packed_scene, "res://level_map.tscn")
	elif event.is_action_pressed("switch_level_0"):
		if PlayerProgress.has_skill(PlayerProgress.Skills.RED):
			load_level(0)
			RealityManagement.switch_level(0)
	elif event.is_action_pressed("switch_level_1"):
		if PlayerProgress.has_skill(PlayerProgress.Skills.GREEN):
			load_level(1)
			RealityManagement.switch_level(1)
	elif event.is_action_pressed("switch_level_2"):
		if PlayerProgress.has_skill(PlayerProgress.Skills.BLUE):
			load_level(2)
			RealityManagement.switch_level(2)

''' LEVEL GENERATION '''
func load_level(level: int = 1, num_layers: int = 4) -> void:
	if levels[level]:
		enable_level(level)
		pass
	else:
		var level_img: Image = preload("uid://d1nmw66apwv8c").get_image()
		#var level_img: Image = preload("uid://18fmxugaoom2").get_image()
		if level_img == null:
			return
		var level_generator: LevelGeneration = LevelGeneration.new()
		level_generator.generate_from_image(level_img, tilemap, level, num_layers)
		tilemap.material.set_shader_parameter("reality_color", PlayerProgress.skill_colors[level])
		
		var packed_scene = PackedScene.new()
		packed_scene.pack(tilemap)
		levels[level] = packed_scene.instantiate()
		ResourceSaver.save(packed_scene, "res://levels/level_%d.tscn" % level)
