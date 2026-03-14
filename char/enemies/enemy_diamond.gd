extends CharBase

func apply_dmg(value: int) -> void:
	stats.hp -= value
	print("applied %d to %s - %s hp left" % [value, name, stats.hp])
	if value > 0:
		velocity.y = -value * 10
