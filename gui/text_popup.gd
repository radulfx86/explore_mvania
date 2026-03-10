extends PopupPanel
class_name TextPopup

@onready var popup_text: RichTextLabel = $PopupText
@export var close_time: float = 1.0
@export var type_time: float = 0.2
@export var min_type_time: float = 0.05
@onready var type_timer: Timer = $TypeTimer 
@onready var close_timer: Timer = $CloseTimer
var type_text: String
var type_pos: int
var special_delays: Dictionary[String, float] = {
	" ": 0.3,
	". ": 0.5
}
var remove_on_close: bool = false


func show_text(text: String, pos: Vector2, remove_upon_close: bool = false) -> void:
	remove_on_close = remove_upon_close
	popup_text.clear()
	type_text = text
	type_pos = 0
	self.position = pos 
	self.popup()
	self.size = Vector2(10,10) + popup_text.get_theme_default_font().get_string_size(text)
	type_timer.start(randf() * type_time)

func show_text_add(master: Node, text: String, pos: Vector2) -> void:
	master.add_child(self)
	show_text(text, pos, true)
	
func type() -> void:
	if type_pos >= type_text.length():
		close_timer.start(close_time)
		return
	var character: String = type_text[type_pos]
	popup_text.add_text(character)
	var delay = special_delays[character] if character in special_delays else 0.0
	popup_text.queue_redraw()
	type_pos += 1
	type_timer.start(delay + min_type_time + randf() * type_time)

func close() -> void:
	print("close?")
	if remove_on_close:
		queue_free()
	else:
		self.hide()
