extends Node2D

var _survived_shown: bool = false

@onready var enemies_node: Node = $Enemies
@onready var survive_label: Label = $CanvasLayer/YouSurviveLabel


func _process(_delta: float) -> void:
	if _survived_shown:
		return

	if enemies_node.get_child_count() > 0:
		return

	_survived_shown = true
	survive_label.visible = true