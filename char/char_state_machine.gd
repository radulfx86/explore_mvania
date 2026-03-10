extends Node
class_name CharStateMachine

enum StateType {
	IDLE,
	MOVE,
	JUMP,
	ATTACK,
	DIE
}

var current: StateType = StateType.IDLE

@export var names: Dictionary[StateType, String] = {
	StateType.IDLE: "idle",
	StateType.JUMP: "jump",
	StateType.MOVE: "move",
	StateType.ATTACK: "attack",
	StateType.DIE: "die"
}

@export var animations: Dictionary[StateType, String] = {
	StateType.IDLE: "idle",
	StateType.JUMP: "idle",
	StateType.MOVE: "run",
	StateType.ATTACK: "attack",
	StateType.DIE: "die"
}

@export var entry_functions: Dictionary[StateType, Callable] = {
	StateType.IDLE: func(): print("entry idle"),
	StateType.JUMP: func(): print("entry jump"),
	StateType.MOVE: func(): print("entry move"),
	StateType.ATTACK: func(): print("entry attack"),
	StateType.DIE: func(): print("entry die")
}

@export var exit_functions: Dictionary[StateType, Callable] = {
	StateType.IDLE: no_action,
	StateType.JUMP: no_action,
	StateType.MOVE: no_action,
	StateType.ATTACK: no_action,
	StateType.DIE: no_action
}

@export var process_functions: Dictionary[StateType, Callable] = {
	StateType.IDLE: no_process,
	StateType.JUMP: no_process,
	StateType.MOVE: no_process,
	StateType.ATTACK: no_process,
	StateType.DIE: no_process
}

@export var check_functions: Dictionary[StateType, Callable] = {
	StateType.IDLE: check_false,
	StateType.JUMP: check_false,
	StateType.MOVE: check_false,
	StateType.ATTACK: check_false,
	StateType.DIE: check_false
}

@export var transitions: Dictionary[StateType, Array] = {
	StateType.IDLE: [StateType.MOVE, StateType.JUMP, StateType.ATTACK, StateType.DIE],
	StateType.JUMP: [StateType.MOVE, StateType.IDLE, StateType.ATTACK, StateType.DIE],
	StateType.MOVE: [StateType.JUMP, StateType.IDLE, StateType.ATTACK, StateType.DIE],
	StateType.ATTACK: [StateType.ATTACK, StateType.MOVE, StateType.IDLE, StateType.DIE],
	StateType.DIE: []
}

func update_state(target: Node) -> void:
	process_functions[current].call(target)
	for test in transitions[current]:
		if check_functions[test].call():
			exit_functions[current].call()
			entry_functions[test].call()
			var animation_name = animations[test]
			if target.has_method("get_animation_prefix"):
				animation_name = target.get_animation_prefix() + animation_name
			print("try to use animation %s" % animation_name)
			if target.animation.sprite_frames.has_animation(animation_name):
				target.animation.play(animation_name)
			else:
				print("no animation for %s found" % animations[test])
			current = test
			return

func no_action() -> void:
	pass
	
func check_false() -> bool:
	return false

func no_process(_target: Node) -> void:
	pass
