extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD	
}

@export_category("Stats")
@export var speed: int = 400
@export var attack_speed: float = 0.6
@export var attack_damage: int  = 60
@export var hitpoints: int = 150
@export_category("Related Scenes")
@export var death_packed: PackedScene = preload("res://assets/effects/death.tscn")

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	if death_packed == null:
		death_packed = preload("res://assets/effects/death.tscn")
	animation_tree.active = true

func _unhandled_input(event: InputEvent) -> void:
	if state == State.DEAD:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()

func _physics_process(_delta: float) -> void:
	if state == State.DEAD:
		return

	if state != State.ATTACK:
		movement_loop()

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	var motion: Vector2 = move_direction.normalized() * speed
	velocity = motion
	move_and_slide()

	if state in [State.IDLE, State.RUN]:
		if move_direction.x < 0:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0:
			$Sprite2D.flip_h = false

	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")

func attack() -> void:
	if state == State.ATTACK or state == State.DEAD:
		return

	state = State.ATTACK

	var mouse_pos: Vector2 = get_global_mouse_position()
	var attck_dir: Vector2 = (mouse_pos - global_position).normalized()
	print(attck_dir)
	$Sprite2D.flip_h = attck_dir.x < 0 and abs(attck_dir.x) >= abs(attck_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attck_dir)

	update_animation()

	await get_tree().create_timer(attack_speed).timeout

	if state == State.DEAD:
		return

	if move_direction != Vector2.ZERO:
		state = State.RUN
	else:
		state = State.IDLE

	update_animation()

func take_damage(damage_taken: int) -> void:
	if state == State.DEAD:
		return

	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()

func death() -> void:
	if state == State.DEAD:
		return

	state = State.DEAD
	velocity = Vector2.ZERO

	if death_packed:
		var death_scene : Node2D = death_packed.instantiate()
		death_scene.position = global_position + Vector2(0.0,-32.0)
		%Effects.add_child(death_scene)
	else:
		push_warning("Player death_packed is not assigned; skipping death effect spawn.")
	queue_free()

func _on_hit_box_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)
