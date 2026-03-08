extends Node2D

const KEY_SCENE: PackedScene = preload("res://assets/effects/key/key.tscn")

var has_key: bool = false
var key_spawned: bool = false

@onready var enemies_node: Node = $Enemies
@onready var door: Area2D = $Door

func _process(_delta: float) -> void:
	if key_spawned:
		return

	if enemies_node.get_child_count() == 0:
		_spawn_key()

func _spawn_key() -> void:
	key_spawned = true

	var key_instance := KEY_SCENE.instantiate() as Area2D
	key_instance.name = "Key"
	key_instance.position = door.position + Vector2(-120, 0)
	key_instance.key_collected.connect(_on_key_collected)

	add_child(key_instance)


func _on_key_collected(_key: Area2D, _collector: Node2D) -> void:
	if has_key:
		return

	has_key = true


func _on_door_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if not has_key:
		return

	get_tree().call_deferred("change_scene_to_file", "res://assets/environment/maps/level3.tscn")