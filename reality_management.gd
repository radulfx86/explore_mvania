extends Node
class_name RealityManagement

static var delay_timer: Timer = Timer.new()
static var delay_time: float = 2.0
static var realilty_level: int = 1
static var target_level: int = 1

class dummy extends Node:
	signal level_switched
static var d: dummy = dummy.new()

func _ready() -> void:
	delay_timer.one_shot = true
	delay_timer.timeout.connect(_delay_timeout)
	add_child(delay_timer)

static func switch_level(tgt_level: int) -> void:
	target_level = tgt_level
	if delay_timer.time_left > 0:
		delay_timer.start(delay_time)
	else:
		_delay_timeout()

static func _delay_timeout() -> void:
	realilty_level = target_level
	d.level_switched.emit()
