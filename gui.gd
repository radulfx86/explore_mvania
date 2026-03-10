extends CanvasLayer
@onready var text_popup: TextPopup = preload("uid://cok7xddd3b6sj").instantiate()
@onready var text_popup2 = preload("uid://cok7xddd3b6sj")

func _ready() -> void:
	add_child(text_popup)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		text_popup.show_text("hello traveller. how are you", get_viewport().get_mouse_position(), false)
	if event.is_action_pressed("attack_melee"):
		text_popup2.instantiate().show_text_add(self,"hello traveller. how are you", get_viewport().get_mouse_position())
