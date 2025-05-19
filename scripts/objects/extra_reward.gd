extends AnimatedSprite2D

var dragging = false
var drag_offset = Vector2.ZERO
var can_drag = true

var reward_id:int = -1

func _input(event: InputEvent) -> void:
	if not can_drag: return
	
	var agent_size = sprite_frames.get_frame_texture("default", 0).get_size() + offset
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var local_pos = to_local(event.position)
				if Rect2(Vector2.ZERO, agent_size).has_point(local_pos):
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
					Global.extra_rewards_position[reward_id] = Vector2(global_position.x / 16, global_position.y / 16)
					
	elif event is InputEventScreenDrag and dragging:
		global_position = event.position + drag_offset
