extends CharBase
class_name Hero

var attack_timer: Timer = Timer.new()
var is_attacking: bool = false

@onready var text_popup = preload("uid://cok7xddd3b6sj")

func _ready() -> void:
	state_machine.check_functions[CharStateMachine.StateType.IDLE] = check_idle
	state_machine.check_functions[CharStateMachine.StateType.JUMP] = check_jump
	state_machine.check_functions[CharStateMachine.StateType.MOVE] = check_move
	state_machine.check_functions[CharStateMachine.StateType.ATTACK] = check_attack
	state_machine.process_functions[CharStateMachine.StateType.IDLE] = handle_idle
	state_machine.process_functions[CharStateMachine.StateType.JUMP] = handle_jump
	state_machine.process_functions[CharStateMachine.StateType.MOVE] = handle_move
	#state_machine.process_functions[CharStateMachine.StateType.ATTACK] = handle_attack
	state_machine.entry_functions[CharStateMachine.StateType.ATTACK] = entry_attack
	attack_timer.one_shot = true
	attack_timer.wait_time = 0.5
	attack_timer.timeout.connect(func() : is_attacking = false; print("attack_timer.timeout"))
	add_child(attack_timer)
	update_animation()
 
func check_idle() -> bool:
	return not Input.is_anything_pressed() or velocity.length_squared() < 1
func check_jump() -> bool:
	return Input.is_action_just_pressed("jump") and is_on_floor()
func check_move() -> bool:
	return Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right")
func check_attack() -> bool:
	return (is_attacking \
				or Input.is_action_just_pressed("attack_melee") \
				or Input.is_action_just_pressed("attack_ranged")) \
			and capabilities.active_ability >= 0 \
			and capabilities.abilities[capabilities.active_ability].type == CharAbility.AbilityType.ATTACK
func entry_attack() -> void:
	if not is_attacking:
		text_popup.instantiate().show_text_add(self,"pow",position)
		var melee: bool = Input.is_action_just_pressed("attack_melee")
		var ranged: bool = Input.is_action_just_pressed("attack_ranged")
		print("attack_timer stopped melee: %s ranged: %s" % [melee, ranged])
		is_attacking = true
		attack_timer.start(capabilities.abilities[capabilities.active_ability].duration)
		if hurt.has_overlapping_bodies():
			for body in hurt.get_overlapping_bodies():
				print("hit %s with %s enemy?: %s" % [body, capabilities.abilities[capabilities.active_ability].name, body.is_in_group("enemies")])
				#if body.is_in_group("enemies"):q
				var enemy: CharBase = body
				enemy.apply_dmg(capabilities.dmg)

func handle_idle(_target: Hero) -> void:
	pass
func handle_move(_target: Hero) -> void:
	direction.x = Input.get_axis("move_left","move_right")
	if direction:
		animation.flip_h = direction.x < 0
		hurt.scale.x = sign(direction.x) * abs(hurt.scale.x)
		velocity.x = direction.x * capabilities.speed
	else:
		velocity.x = move_toward(velocity.x, 0, capabilities.speed)
func handle_jump(_target: Hero) -> void:
	if is_on_floor():
		velocity.y = capabilities.jump
func handle_attack(_target: Hero) -> void:
	# nothing to do
	pass
