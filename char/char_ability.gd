extends Resource
class_name CharAbility

enum AbilityType {
	MOVE,
	ATTACK,
	LIFE,
	DEFEND
}
@export var name: String
@export var value: int
@export var duration: float
@export var range: int
@export var type: AbilityType
