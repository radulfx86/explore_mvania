extends CharBase
class_name Hero

var is_jumping: bool = false

@onready var text_popup = preload("uid://cok7xddd3b6sj")

func _ready() -> void:
	initialize()

func initialize() -> void:
	super.initialize()
	state_machine.check_functions[CharStateMachine.StateType.IDLE] = check_idle
	state_machine.check_functions[CharStateMachine.StateType.JUMP] = check_jump
	state_machine.check_functions[CharStateMachine.StateType.MOVE] = check_move
	state_machine.check_functions[CharStateMachine.StateType.ATTACK] = check_attack
	state_machine.process_functions[CharStateMachine.StateType.IDLE] = handle_idle
	state_machine.process_functions[CharStateMachine.StateType.JUMP] = handle_jump
	state_machine.process_functions[CharStateMachine.StateType.MOVE] = handle_move
	state_machine.process_functions[CharStateMachine.StateType.ATTACK] = handle_attack
	state_machine.entry_functions[CharStateMachine.StateType.ATTACK] = entry_attack
	state_machine.entry_functions[CharStateMachine.StateType.JUMP] = jump_enter
	state_machine.exit_functions[CharStateMachine.StateType.JUMP] = jump_exit 
	#state_machine.exit_functions[CharStateMachine.StateType.MOVE] = func() : velocity.x = 0.0
	update_animation()
	attack_timer.wait_time = 0.5
	state_machine.entry_functions[CharStateMachine.StateType.DIE] = func(): death_timer.start(1.0); prepare_gameover
	death_timer.timeout.connect(gameover)
 
func check_idle() -> bool: 
	return not Input.is_anything_pressed() or velocity.length_squared() < 1
func check_jump() -> bool:
	return (is_jumping == false && Input.is_action_just_pressed("jump")) and is_on_floor()
func check_move() -> bool:
	return Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
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
				print("hit %s with %s enemy?: %s %s" % [body, capabilities.abilities[capabilities.active_ability].name, body.is_in_group("enemies"), body.char_name])
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
	if is_on_floor() and is_jumping:
		velocity.y = capabilities.jump
		is_jumping = false
func handle_attack(_target: Hero) -> void:
	print("handle_attack( %s ) - %s" % [_target, name])
	# nothing to do
	pass
func jump_exit() -> void:
	is_jumping = false
func jump_enter() -> void:
	is_jumping = true 

func prepare_gameover() -> void:
	pass

func gameover() -> void:
	get_tree().change_scene_to_file("uid://dbcjk18w4x51a")
