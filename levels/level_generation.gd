extends Node
class_name LevelGeneration

var level_map: BitMap = BitMap.new()
var level_size: Vector2i

func generate_from_image(level_img: Image, tilemap: TileMapLayer, level: int = 0, num_layers: int = 1) -> void:
	level_size = level_img.get_size() / Vector2i(1,num_layers)
	level_map.create_from_image_alpha(level_img)
	tilemap.clear()
	_fill_grid(tilemap, level)

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
					tgt_tile = Vector2i(int(cnt % 4), int(cnt / 4))
				target_map.set_cell(Vector2i(_x,_y-offset * level_size.y), 1, tgt_tile)
