extends Node2D
class_name DefaultLevel

@export var tiles_map: TileMapLayer

func init() -> void:
	disable()

func enable(value: bool = true) -> void:
	print("enable %s : %s" % [name, value])
	if tiles_map:
		tiles_map.visible = value
		tiles_map.enabled = value
	else:
		print("%s does not have a tile map assigned" % name)
	if has_node("Items"):
		for x in $Items.get_children():
			x.visible = value
	if has_node("NPCs"):
		for x in $NPCs.get_children():
			x.visible = value
			#x.enabled = value

func disable() -> void:
	enable(false)
