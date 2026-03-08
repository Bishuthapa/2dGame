extends Area2D

signal key_collected(key: Area2D, collector: Node2D)

@export var player_group_name: StringName = &"player"

var _is_collected: bool = false


func _ready() -> void:
	# Make sure the key animation plays as soon as it appears.
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("RESET")

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _is_collected:
		return

	if not body.is_in_group(player_group_name):
		return

	_is_collected = true
	key_collected.emit(self, body)
	queue_free()
