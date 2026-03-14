extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer

@export var level_layers: int = 4

@onready var levels: Array[TileMapLayer] = [
	null,
	null,
	null,
	null,
	#preload("res://levels/level_0.tscn").instantiate(),
	#preload("res://levels/level_1.tscn").instantiate(),
	#preload("res://levels/level_2.tscn").instantiate(),
	#preload("res://levels/level_3.tscn").instantiate(),
]

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

''' LEVEL GENERATION '''
func load_level(level: int = 1, num_layers: int = 4) -> void:
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
	var success = ResourceSaver.save(packed_scene, "res://levels/generated/tiles_%d.tscn" % level)
	print("saved level %d - status: %s" % [level, success])
