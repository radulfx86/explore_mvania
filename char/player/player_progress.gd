extends Node
class_name PlayerProgress

enum Skills
{
	RED,
	GREEN,
	BLUE,
	NUM_SKILLS
}

static var skill_colors: Array[Color]= [
	Color(1,0,0,1),
	Color(0,1,0,1),
	Color(0,0,1,1),
	Color(1,1,1,1),
]

static var max_life: int = 10
static var life: int = 1

static var unlocked_skills: int = 0

static func unlock_skill(skill: Skills) -> void:
	unlocked_skills |= 1<<skill
	print_unlocked_skills()

static func clear_skill(skill: Skills) -> void:
	unlocked_skills &= 1<<skill

static func has_skill(skill: Skills) -> bool:
	return unlocked_skills & (1<<skill)

static func print_unlocked_skills() -> void:
	print("unlocked skills:")
	for s in range(Skills.NUM_SKILLS):
		print(" skill %s: %s" % [s, has_skill(s as Skills)])
