extends Resource
class_name CharCapabilities

@export var speed: int:
	get():
		var speed_sum: int = speed
		for ability in abilities:
			if ability.type == CharAbility.AbilityType.MOVE:
				speed_sum += abilities[active_ability].value
		return speed_sum
@export var jump: int
@export var hp: int:
	get():
		var hp_sum: int = hp
		for ability in abilities:
			if ability.type == CharAbility.AbilityType.LIFE:
				hp_sum += abilities[active_ability].value
		return hp_sum
@export var dmg: int:
	get():
		var dmg_sum: int = dmg
		if active_ability && abilities[active_ability].type == CharAbility.AbilityType.ATTACK:
			dmg_sum += abilities[active_ability].value
		return dmg_sum
@export var def: int:
	get():
		var def_sum: int = def
		for ability in abilities:
			if ability.type == CharAbility.AbilityType.DEFEND:
				def_sum += abilities[active_ability].value
		return def_sum
@export var active_ability: int = 0
@export var abilities: Array[CharAbility]
