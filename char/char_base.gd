extends CharacterBody2D
class_name CharBase

@export var capabilities: CharCapabilities
@export var stats: CharStats
@export var state_machine: CharStateMachine = CharStateMachine.new()
@export var char_name: String

@export var animation: AnimatedSprite2D:
	set(a):
		animation = a

@export var hit: Area2D:
	set(h):
		hit = h
		#hit.area_entered.connect(_on_area_entered)
		#hit.area_exited.connect(_on_area_exited)
		hit.body_entered.connect(_on_body_entered)
		hit.body_exited.connect(_on_body_exited)
		
@export var hurt: Area2D

@export var direction: Vector2 = Vector2(1,0)
var death_timer: Timer = Timer.new()

func _ready() -> void:
	state_machine.check_functions[CharStateMachine.StateType.DIE] = func(): return stats.hp <= 0
	state_machine.entry_functions[CharStateMachine.StateType.DIE] = func(): death_timer.start(1.0)
	death_timer.one_shot = true
	death_timer.timeout.connect(func(): queue_free())
	add_child(death_timer)
	update_animation()

func update_animation() -> void:
	if animation.sprite_frames.has_animation(state_machine.animations[state_machine.current]):
		animation.play(state_machine.animations[state_machine.current])

func apply_dmg(value: int) -> void:
	stats.hp -= value
	print("applied %d to %s - %s hp left" % [value, name, stats.hp])
	if value > 0:
		velocity.y = -value * 10

func get_animation_prefix() -> String:
	print("requested animation prefix -> %d_%s_" % [RealityManagement.realilty_level, char_name])
	return "%d_%s_" % [RealityManagement.realilty_level, char_name]

func _physics_process(delta: float) -> void:
	state_machine.update_state(self)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func _on_area_entered(area: Area2D) -> void:
	print("_on_area_entered(%s) of %s" % [area, name])
	pass
	
func _on_body_entered(body: Node) -> void:
	print("_on_body_entered(%s) of %s" % [body, name])
	pass
	
func _on_area_exited(_area: Area2D) -> void:
	pass

func _on_body_exited(body: Node) -> void:
	print("_on_body_exited(%s) of %s" % [body, name])
	pass
