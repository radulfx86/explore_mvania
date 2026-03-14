extends Node2D
class_name Level2

@export var tiles_map: TileMapLayer

func init() -> void:
	disable()

func enable(value: bool = true) -> void:
	tiles_map.visible = value
	tiles_map.enabled = value
	for x in $Items.get_children():
		x.visible = value

func disable() -> void:
	enable(false)
