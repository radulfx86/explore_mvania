extends CharacterBody2D
class_name CharBase

var attack_timer: Timer = Timer.new()
var is_attacking: bool = false
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
signal hp_changed

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
var death_timer: Timer

func _ready() -> void:
	initialize()

func initialize() -> void:
	death_timer = Timer.new()
	state_machine.check_functions[CharStateMachine.StateType.DIE] = func(): return stats.hp <= 0
	state_machine.entry_functions[CharStateMachine.StateType.DIE] = func(): death_timer.start(1.0)
	state_machine.process_functions[CharStateMachine.StateType.MOVE] = move_npc
	state_machine.check_functions[CharStateMachine.StateType.MOVE] = check_move
	state_machine.check_functions[CharStateMachine.StateType.ATTACK] = check_attack
	state_machine.entry_functions[CharStateMachine.StateType.ATTACK] = entry_attack
	death_timer.one_shot = true
	death_timer.timeout.connect(queue_free)
	add_child(death_timer)
	update_animation()
	check_path()
	if detection_area:
		detection_area.body_entered.connect(_on_target_body_entered)
		detection_area.body_exited.connect(_on_target_body_exited)
	attack_timer.one_shot = true
	attack_timer.wait_time = 0.5
	attack_timer.timeout.connect(func() : is_attacking = false; print("base attack_timer.timeout: %s" % name))
	add_child(attack_timer)

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
			animation.flip_h = direction.x > 0
			hurt.scale.x = sign(direction.x) * abs(hurt.scale.x)
			velocity.x = direction.x * capabilities.speed
		else:
			velocity.x = move_toward(velocity.x, 0, capabilities.speed)
		return
	if path:
		update_path()
		if direction:
			velocity.x = direction.x * capabilities.speed
			animation.flip_h = direction.x > 0
		else:
			velocity.x = move_toward(velocity.x, 0, capabilities.speed)
	else:
		direction = (next_pos - global_position).normalized()

func check_move() -> bool:
	if path:
		return path_points.size() > 0
	else:
		return target != null
func check_attack() -> bool:
	var has_attack = capabilities.abilities.size() > 0 \
		and capabilities.active_ability >= 0 \
		and capabilities.abilities[capabilities.active_ability].type == CharAbility.AbilityType.ATTACK
	var is_in_attack_range = has_attack \
		and target != null \
		and capabilities.abilities[capabilities.active_ability].range >= (target.global_position - global_position).length()
	var do_check_attack = ((is_attacking and has_attack) or is_in_attack_range)
	if target != null:
		print("check attack %s has_attack: %s is_attacking: %s is_in_attack_range: %s range: %s >= %s " 
				% [name,
				has_attack,
				is_attacking,
				is_in_attack_range,
				capabilities.abilities[capabilities.active_ability].range, 
				(target.global_position - global_position).length()] )
	else:
		print("check attack without target for %s - target: %s" % [name, target])
	return do_check_attack
func entry_attack() -> void:
	print("entry attack %s is attacking %s" % [name, is_attacking])
	if not is_attacking:
		#text_popup.instantiate().show_text_add(self,"a ha",position)
		is_attacking = true
		attack_timer.start(capabilities.abilities[capabilities.active_ability].duration)
		if hurt.has_overlapping_bodies():
			for body in hurt.get_overlapping_bodies():
				print("hit %s with %s enemy?: %s %s" % [body, capabilities.abilities[capabilities.active_ability].name, body.is_in_group("enemies"), body.char_name])
				var free_to_attack = true
				for g in get_groups():
					if body.is_in_group(g):
						free_to_attack = false
						break
				print("hit %s -> %s is free to attack: %s" % [name, body, free_to_attack])
				if free_to_attack:
					var enemy: CharBase = body
					enemy.apply_dmg(capabilities.dmg)

func update_animation() -> void:
	var animation_name: String = "%s%s" % [get_animation_prefix(), state_machine.animations[state_machine.current]]
	print("%s.update_animation() -> %s" % [name, animation_name])
	if animation.sprite_frames.has_animation(animation_name):
		print("play animation: %s %s" % [name, animation_name])
		animation.play(animation_name)

func apply_dmg(value: int) -> void:
	stats.hp -= value
	print("hit applied %d to %s - %s hp left" % [value, name, stats.hp])
	if value > 0:
		velocity.y = -value * 10
	hp_changed.emit()

func get_animation_prefix() -> String:
	#print("requested animation prefix -> %d_%s_" % [RealityManagement.realilty_level, char_name])
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
			print("_on_target_body_entered(%s) of %s - in same group" % [_target, name])
			return
	print("_on_target_body_entered(%s) of %s - new target" % [_target, name])
	target = _target
	next_pos == target.global_position

func _on_target_body_exited(_target: Node2D) -> void:
	print("_on_target_body_exited(%s) of %s" % [_target, name])
	if _target == target:
		print("_on_target_body_exited(%s) of %s clearing target" % [_target, name])
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
