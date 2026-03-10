extends Area2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
enum ItemType
{
	UPDATE_ABILITY,
	UPDATE_STATS,
	NUM_BEHAVIOURS
}
@export var item_type: ItemType
''' TODO use variant and/or resource to have parameters for both stats update and ability update (and more?) '''
@export var value: int

func _ready() -> void:
	animation.play()
	var t = animation.get_sprite_frames().get_frame_texture(animation.animation, animation.get_frame())                                                                                                               
	animation.material.set_shader_parameter("frameTex", t)
	animation.material.set_shader_parameter("texSize", t.get_atlas().get_size())
	animation.material.set_shader_parameter("frameOffset", t.get_region().position)
	animation.material.set_shader_parameter("frameSize",  t.get_region().size)  


func _on_body_entered(body: Node2D) -> void:
	collect(body)
	queue_free()

func collect(_collector: Node2D) -> void:
	if item_type == ItemType.UPDATE_ABILITY:
		PlayerProgress.unlock_skill(value as PlayerProgress.Skills)
	elif item_type == ItemType.UPDATE_STATS:
		if _collector.has_method("apply_dmg"):
			_collector.apply_dmg(-value)
	else:
		pass
