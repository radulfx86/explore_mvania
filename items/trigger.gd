extends Area2D
@export var hero: Hero
signal triggered

func _on_body_entered(body: Node2D) -> void:
	print("hit trigger by %s" %body)
	if body.is_in_group("player"):
		print("hit trigger")
	triggered.emit(body)
