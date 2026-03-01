extends CharacterBody2D

@export_category("Status")
@export var hitpoints:int = 100

func take_damage(damage_taken : int) -> void:
	hitpoints -= damage_taken
	if hitpoints <= 0:
		queue_free()
