extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer

var level_map: BitMap = BitMap.new()
var level_size: Vector2i
@export var level_layers: int = 3
@onready var tex_rect: TextureRect = $TextureRect

@onready var levels: Array[TileMapLayer] = [
	preload("res://levels/level_0.tscn").instantiate(),
	preload("res://levels/level_1.tscn").instantiate(),
	preload("res://levels/level_2.tscn").instantiate(),
]

@onready var text_popup = preload("uid://cok7xddd3b6sj")

func _ready() -> void:
	for l in levels:
		#l.visible = false
		#l.enabled = false
		#add_child(l)
		pass
	#enable_level(0)
	load_level(0)
	pass

func enable_level(i: int) -> void:
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
		#enable_level(0)
		load_level(0)
	elif event.is_action_pressed("switch_level_1"):
		#enable_level(1)
		load_level(1)
	elif event.is_action_pressed("switch_level_2"):
		#enable_level(2)
		load_level(2)

''' LEVEL GENERATION '''
func load_level(level: int = 1, num_layers: int = 3) -> void:
	if levels[level]:
		enable_level(level)
		pass
	else:
		var level_img: Image = preload("uid://d1nmw66apwv8c").get_image()
		#var level_img: Image = preload("uid://18fmxugaoom2").get_image()
		if level_img == null:
			return
		level_size = level_img.get_size() / Vector2i(1,num_layers)
		level_map.create_from_image_alpha(level_img)
		tilemap.clear()
		_fill_grid(tilemap, level)
		
		var packed_scene = PackedScene.new()
		packed_scene.pack(tilemap)
		levels[level] = packed_scene.instantiate()
		ResourceSaver.save(packed_scene, "res://levels/level_%d.tscn" % level)

func __is_valid_grid(_x:int, _y:int, _offset: int = 0) -> bool:
	return (_x >= 0 && _y >= _offset * level_size.y && _x < level_size.x && _y < (1+_offset) * level_size.y)

func __check_pt(_x:int, _y:int, _offset: int = 0,_value:bool=false) -> bool:
	return __is_valid_grid(_x,_y,_offset) && level_map.get_bit(_x,_y) == _value

func _count_neighbors(_x:int, _y:int, _offset: int=0, _value:bool=false) -> int:
	''' count neighbors, to generate orientation. get unique value by adding "binary" values assigned to edges:
		1  1/2  2
		1/4  X  2/8
		4  4/8  8
	'''
	var cnt = 0
	if __check_pt(_x-1,_y-1,_offset,_value) && __check_pt(_x,_y-1,_offset,_value) && __check_pt(_x-1,_y,_offset,_value):
		cnt += 1
	if __check_pt(_x+1,_y-1,_offset,_value) && __check_pt(_x,_y-1,_offset,_value) && __check_pt(_x+1,_y,_offset,_value):
		cnt += 2
	if __check_pt(_x-1,_y+1,_offset,_value) && __check_pt(_x,_y+1,_offset,_value) && __check_pt(_x-1,_y,_offset,_value):
		cnt += 4
	if __check_pt(_x+1,_y+1,_offset,_value) && __check_pt(_x,_y+1,_offset,_value) && __check_pt(_x+1,_y,_offset,_value):
		cnt += 8
	return cnt
	
func _fill_grid(target_map: TileMapLayer, offset: int = 0) -> void:
	var s: Array[int]
	for _ty in range(0, level_size.y):
		for _x in range(0, level_size.x):
			var _y = _ty + offset * level_size.y
			if level_map.get_bit(_x,_y) == true:
				var cnt = _count_neighbors(_x, _y, offset, true)
				if not cnt in s:
					s.append(cnt)
				var tgt_tile = Vector2i(1,1)
				if cnt >= 0 && cnt < 16:
					tgt_tile = Vector2i(cnt % 4, cnt / 4)
				target_map.set_cell(Vector2i(_x,_y-offset * level_size.y), 1, tgt_tile)
