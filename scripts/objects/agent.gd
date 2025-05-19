extends AnimatedSprite2D

signal movement_finished
signal reward_find

const TILE_SIZE = 16
var moving = false
var paused = false
var direction = Vector2.ZERO
var target_position = Vector2.ZERO
var move_speed = 50.0
var path_idx = 0

var positions = []

var dragging = false
var drag_offset = Vector2.ZERO
var can_drag = true

func _input(event: InputEvent) -> void:
	if not can_drag: return
	
	var agent_size = sprite_frames.get_frame_texture("idle_front", 0).get_size() + offset
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var local_pos = to_local(event.position)
				if Rect2(Vector2.ZERO, agent_size).has_point(local_pos):
					print(position, " ", event.position)
					dragging = true
					drag_offset = position - event.position
			else:
				if dragging:
					dragging = false
					var index_global_position = global_position / 16
					if global_position.x < 0:
						global_position.x = 0
					if global_position.x > (Global.grid_size.x - 1) * 16:
						global_position.x =  (Global.grid_size.x - 1) * 16
					if global_position.y < 0:
						global_position.y = 0
					if global_position.y > (Global.grid_size.y - 1) * 16:
						global_position.y = (Global.grid_size.y - 1) * 16
					
					global_position = Vector2(global_position).snapped(Vector2(16, 16))
	elif event is InputEventScreenDrag and dragging:
		global_position = event.position + drag_offset
			
func move(path) -> void:
	positions = path
	
	for i in positions.size():
		positions[i] = Vector2(positions[i] * TILE_SIZE)
	
	position = positions[0]
	path_idx = 1
	await get_tree().create_timer(1.5).timeout
	moving = true
	

func _ready():
	play("idle_front")
	#TODO: verificar direção inicial (bom ele se consertar depois de andar um tile, faz até um moonwalk
	walk_animation()
	

func walk_animation():
	if direction == Vector2.DOWN:
		play("walk_front")
	elif direction == Vector2.UP:
		play("walk_back")
	elif direction == Vector2.LEFT:
		play("walk_left")
	elif direction == Vector2.RIGHT:
		play("walk_right")

func idle_animation():
	if direction == Vector2.DOWN:
		play("idle_front")
	elif direction == Vector2.UP:
		play("idle_back")
	elif direction == Vector2.LEFT:
		play("idle_left")
	elif direction == Vector2.RIGHT:
		play("idle_right")

func _process(delta: float) -> void:
	if not moving or paused:
		return
	
	if path_idx >= positions.size():
		return
	var next_position = positions[path_idx]
	position = position.move_toward(next_position, move_speed * delta)
	
	if position.distance_to(next_position) < 0.5:
		var i = 0
		for reward_position in Global.extra_rewards_position:
			if  abs(position.x - reward_position.x * 16) < 1 and abs(position.y - reward_position.y * 16) < 1:
				paused = true
				idle_animation()
				await get_tree().create_timer(1.0).timeout
				paused = false
				
				emit_signal("reward_find", Vector2(reward_position.x * 16, reward_position.y * 16))
				
				walk_animation()
				break
			i += 1
		
		position = next_position
		
		path_idx += 1
			
		if path_idx >= positions.size():
			emit_signal("movement_finished")
			idle_animation()
			return
			
		var next_direction = positions[path_idx] - position 
		if next_direction.x > 0:
			direction = Vector2.RIGHT
		elif next_direction.x < 0:
			direction = Vector2.LEFT
		elif next_direction.y > 0:
			direction = Vector2.DOWN
		elif next_direction.y < 0:
			direction = Vector2.UP
		
		walk_animation()
		
