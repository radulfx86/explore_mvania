extends CharacterBody2D
class_name CharBase

@export var capabilities: CharCapabilities
@export var stats: CharStats
@export var state_machine: CharStateMachine = CharStateMachine.new()
@export var char_name: String
@export var path: Path2D
var next_pos: Vector2
var path_points: PackedVector2Array
var path_idx: int = 0
var path_dir: int = 1
@export var update_dist: float = 10.0
@export var detection_area: Area2D
var target: Node = null

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
	state_machine.process_functions[CharStateMachine.StateType.MOVE] = move_npc
	state_machine.check_functions[CharStateMachine.StateType.MOVE] = check_move
	state_machine.check_functions[CharStateMachine.StateType.ATTACK] = check_attack
	death_timer.one_shot = true
	death_timer.timeout.connect(func(): queue_free())
	add_child(death_timer)
	update_animation()
	check_path()
	if detection_area:
		detection_area.body_entered.connect(_on_target_body_entered)
		detection_area.body_exited.connect(_on_target_body_exited)

func check_path() -> void:
	if path:
		path_points = (path.curve.get_baked_points() as Array).map(func (e): return e + path.global_position)
	print("path available: %s with %d points" %  [path, path_points.size()])

func update_path() -> bool:
	next_pos = path_points[path_idx]
	var diff = next_pos - global_position
	if diff.length() < update_dist:
		if path_idx + path_dir >= path_points.size() or path_idx + path_dir < 0:
			path_dir = - path_dir
		path_idx += path_dir
		return true
	direction = diff.normalized()
	return false

''' state machine override functions '''
func move_npc(_target: Node) -> void:
	if target:
		direction = (target.global_position - global_position).normalized()
		if direction:
			animation.flip_h = direction.x < 0
			hurt.scale.x = sign(direction.x) * abs(hurt.scale.x)
			velocity.x = direction.x * capabilities.speed
		else:
			velocity.x = move_toward(velocity.x, 0, capabilities.speed)
		print("%s t direction %s velocity %s" % [name, direction, velocity])
		return
	if path:
		update_path()
		if direction:
			velocity.x = direction.x * capabilities.speed
			animation.flip_h = direction.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, capabilities.speed)
		print("p direction %s velocity %s" % [direction, velocity])
	else:
		direction = (next_pos - global_position).normalized()
		print("e direction %s velocity %s" % [direction, velocity])
	'''
func handle_move(_target: Hero) -> void:
	direction.x = Input.get_axis("move_left","move_right")
	if direction:
		animation.flip_h = direction.x < 0
		hurt.scale.x = sign(direction.x) * abs(hurt.scale.x)
		velocity.x = direction.x * capabilities.speed
	else:
		velocity.x = move_toward(velocity.x, 0, capabilities.speed)
		'''
func check_move() -> bool:
	if path:
		return path_points.size() > 0
	else:
		return target != null
func check_attack() -> bool:
	return false

func update_animation() -> void:
	if animation.sprite_frames.has_animation(state_machine.animations[state_machine.current]):
		animation.play("%s_%s" % [get_animation_prefix(), state_machine.animations[state_machine.current]])

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

func _on_target_body_entered(_target: Node2D) -> void:
	print("_on_target_body_entered(%s) of %s" % [_target, name])
	for g in get_groups():
		if _target.is_in_group(g):
			print("nah, familiar")
			return
	print("target itentified")
	target = _target
	next_pos == target.global_position

func _on_target_body_exited(_target: Node2D) -> void:
	print("_on_target_body_exited(%s) of %s" % [_target, name])
	if _target == target:
		print("clearing target")
		target = null

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
