extends Node2D
class_name Interactable

@export var interaction_area: Area2D
var interactions: Array[Area2D]

func _ready() -> void:
	interaction_area.area_entered.connect(_on_interact_area_entered)
	interaction_area.area_exited.connect(_on_interact_area_exited)

func _on_interact_area_entered(area: Area2D) -> void:
	interactions.push_back(area)
func _on_interact_area_exited(area: Area2D) -> void:
	interactions.erase(area)
