extends CanvasLayer
@onready var animated_item = preload("uid://o63f7m7l1njr")
@onready var life_info_label: Label = $p/h/v/h_life/LifeInfoLabel
@onready var level_info_label: Label = $p/h/v/h_reality/RealityInfoLabel
@onready var life_info_placeholder: Control = $p/h/v/h_life/LifeInfoPlaceholder
@onready var level_info_placeholder: Control = $p/h/v/h_reality/RealityInfoPlaceholder
@onready var reality_placeholder: Control = $p/h/RealityPlaceholder
var reality_icons: Array[AnimatedSprite2D]
var current_reality: AnimatedSprite2D

func _ready() -> void:
	
	var width: int = max(life_info_label.size.x, level_info_label.size.x) + 20
	life_info_label.size.x = width
	level_info_label.size.x = width
	
	init_squares(width)
	
	init_hearts(width)

func init_squares(width: int) -> void:
	var c: int = 0
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://shader/gui_health.gdshader")
	for r in PlayerProgress.skill_colors:
		var square: AnimatedSprite2D = animated_item.instantiate()
		square.play("square")
		square.position.x += width + 20 * c
		square.position.y += level_info_label.size.y/2
		reality_icons.append(square)
		level_info_label.add_child(square)
		square.material = mat.duplicate()
		square.material.set_shader_parameter("test_color", r)
		c += 1
	
	current_reality = animated_item.instantiate()
	current_reality.play("square")
	current_reality.scale = Vector2(2,2)
	current_reality.position.x += reality_placeholder.size.x/2
	current_reality.position.y += level_info_label.size.y
	reality_icons.append(current_reality)
	reality_placeholder.add_child(current_reality)
	current_reality.material = mat.duplicate()
	current_reality.material.set_shader_parameter("test_color", PlayerProgress.skill_colors[0])

func init_hearts(width: int) -> void:
	var c:int = 0
	for r in range(PlayerProgress.max_life):
		var heart: AnimatedSprite2D = animated_item.instantiate()
		heart.play("heart")
		heart.position.x += width + 20 * c
		heart.position.y += level_info_label.size.y/2
		#life_info_placeholder.add_child(heart)
		life_info_label.add_child(heart)
		heart.material.set_shader_parameter("test_color", Color.RED)
		c += 1
	
	RealityManagement.d.level_switched.connect(update_level)
	
func update_level() -> void:
	current_reality.material.set_shader_parameter("test_color", PlayerProgress.skill_colors[RealityManagement.realilty_level])
	
