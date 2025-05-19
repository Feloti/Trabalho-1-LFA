extends Node2D

@onready var tilemap: TileMap = $TileMap
var initial_agent_position: Vector2

var agent: AnimatedSprite2D
var agent_scene:PackedScene = load("res://scenes/agents/agent.tscn")
var chest_scene:PackedScene = load("res://scenes/objects/chest.tscn")
var reward_scene:PackedScene = load("res://scenes/objects/extra_reward.tscn")
@onready var algoritm_options:OptionButton = $OptionButton

var result: Dictionary
var metrics_initial_pos_y: int = 5
var metrics_container = {}

var rng:RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	
	var generator = TerrainGenerator.new(Global.grid_size.x, Global.grid_size.y, 1.0)
	Global.grid =  generator.generate_terrain([1, 1, 1, 1], false)
	var rewards = generator.generate_rewards(5)
	Global.goal_position = rewards[0]
	Global.extra_rewards_position = rewards[1]
	#Cria os tiles com base nos valores da matriz gerada
	apply_terrain_to_tilemap()
	
	#Adiciona as opções dos algoritmos
	algoritm_options.add_item("BFS")
	algoritm_options.add_item("DFS")
	algoritm_options.add_item("Greedy")
	algoritm_options.add_item("A*")
	
	#Instacia Agente
	agent = agent_scene.instantiate()
	add_child(agent)
	initial_agent_position = agent.position
	
	#Instancia objetivo final (bau)
	spawn_chest()
	spawn_rewards()
	move_child($Chest, get_child_count())
	
	#agent.connect("movement_finished", Callable($Chest.get_child(0), "open"))
	agent.connect("reward_find", Callable(self, "remove_reward"))
	


func create_metrics_labels(nodes_visited: int, nodes_expanded: int, path_len: int, path_cost:int, 
initial_pos_y: int, algorithm_choice: String):
	var container
	
	if metrics_container.has(algorithm_choice):
		container = metrics_container[algorithm_choice]
		container.get_node("VisitedLabel").text = "Nós Visitados: %s" % nodes_visited
		container.get_node("ExpandedLabel").text = "Nós Expandidos: %s" % nodes_expanded
		container.get_node("PathLabel").text = "Caminho Tamanho: %s" % path_len
		container.get_node("CostLabel").text = "Caminho Custo: %s" % path_cost
	else:
		container = Node2D.new()
		container.name = algorithm_choice
		$AlgorithmMetrics.add_child(container)
		
		var background_algorithm_name = ColorRect.new()
		background_algorithm_name.color = Color(1, 0, 0)
		background_algorithm_name.position = Vector2(530, initial_pos_y) #5
		background_algorithm_name.size = Vector2(110, 18)
		
		var algorithm_name = Label.new()
		algorithm_name.position = Vector2(530, initial_pos_y)
		algorithm_name.size = Vector2(110, 20)
		algorithm_name.text = algorithm_choice
		algorithm_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		algorithm_name.add_theme_font_size_override("font_size", 12)
		container.add_child(background_algorithm_name)
		container.add_child(algorithm_name)
		
		var metric_nodes_visited:Label = Label.new()
		metric_nodes_visited.name = "VisitedLabel"
		metric_nodes_visited.position = Vector2(530, initial_pos_y + 20)
		metric_nodes_visited.size = Vector2(110, 20)
		metric_nodes_visited.text = "Nós Visitados: %s" % nodes_visited
		metric_nodes_visited.add_theme_font_size_override("font_size", 9)
		metric_nodes_visited.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(metric_nodes_visited)

		var metric_nodes_expanded:Label = Label.new()
		metric_nodes_expanded.name = "ExpandedLabel"
		metric_nodes_expanded.position = Vector2(530, initial_pos_y + 35)
		metric_nodes_expanded.size = Vector2(110, 20)
		metric_nodes_expanded.text = "Nós Expandidos: %s" % nodes_expanded
		metric_nodes_expanded.add_theme_font_size_override("font_size", 9)
		metric_nodes_expanded.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(metric_nodes_expanded)
		
		var metric_nodes_path:Label = Label.new()
		metric_nodes_path.name = "PathLabel"
		metric_nodes_path.position = Vector2(530, initial_pos_y + 50)
		metric_nodes_path.size = Vector2(110, 20)
		metric_nodes_path.text = "Caminho Tamanho: %s" % path_len
		metric_nodes_path.add_theme_font_size_override("font_size", 9)
		metric_nodes_path.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(metric_nodes_path)
		
		var metric_nodes_cost:Label = Label.new()
		metric_nodes_cost.name = "CostLabel"
		metric_nodes_cost.position = Vector2(530, initial_pos_y + 65)
		metric_nodes_cost.size = Vector2(110, 20)
		metric_nodes_cost.text = "Caminho Custo: %s" % path_cost
		metric_nodes_cost.add_theme_font_size_override("font_size", 9)
		metric_nodes_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(metric_nodes_cost)
		
		metrics_container[algorithm_choice] = container
		metrics_initial_pos_y += 90

func spawn_chest():
	#Instancia objetivo final (bau)
	if $Chest.get_child_count() > 0:
		$Chest.get_child(0).queue_free()
		
	var chest:AnimatedSprite2D = chest_scene.instantiate()
	chest.position = Global.goal_position * 16
	$Chest.add_child(chest)
	
	agent.connect("movement_finished", Callable(chest, "open"))

func spawn_rewards() -> void:
	for reward in $Rewards.get_children():
		reward.queue_free()
		
	var i = 0
	for reward_position in Global.extra_rewards_position:
		var reward:AnimatedSprite2D = reward_scene.instantiate()
		reward.position = reward_position * 16
		reward.reward_id = i
		$Rewards.add_child(reward)
		i += 1

func remove_reward(grid_pos: Vector2):
	for reward in $Rewards.get_children():
		if reward.position == grid_pos:
			reward.queue_free()
			break

func paint_path(path):
	await get_tree().create_timer(1.5).timeout
	for node in path:
		tilemap.set_cell(0, node / 16, 102, Vector2i(2, 0))

func paint_expanded(nodes_expanded):
	await get_tree().create_timer(1.5).timeout
	for node in nodes_expanded:
		tilemap.set_cell(0, node, 101, Vector2i(2, 0))

func paint_visited(nodes_visited):
	await get_tree().create_timer(1.5).timeout
	for node in nodes_visited:
		tilemap.set_cell(0, node, 100, Vector2i(2, 0)) #vermelho

func _physics_process(delta: float) -> void:
	pass

func apply_terrain_to_tilemap() -> void:
	tilemap.clear()
	
	for y in range(Global.grid_size.y):
		for x in range(Global.grid_size.x):
			var terrain_type = Global.grid[y][x]
			
			var test_x = rng.randi() % 5 
			var test_y = rng.randi() % 2 
			if test_x == 4 and test_y == 1:
				test_x = 3
			
			if terrain_type == -1:
				tilemap.set_cell(0, Vector2i(x, y), terrain_type, Vector2i(4, 4))
			else:
				tilemap.set_cell(0, Vector2i(x, y), terrain_type, Vector2i(test_x, test_y))
	
func _on_start_pressed() -> void:
	if result.has("node_visited"):
		result.nodes_visited.clear()
		result.nodes_expanded.clear()
	
	initial_agent_position = agent.position
	
	var agent_position_grid = Vector2(agent.position.x / 16, agent.position.y / 16)
	var chest_position_grid = Vector2($Chest.get_child(0).position.x / 16, $Chest.get_child(0).position.y / 16)
	
	if algoritm_options.text == "BFS":
		result = BFS.new().search(Global.grid, agent_position_grid, chest_position_grid)
	elif algoritm_options.text == "DFS":
		result = DFS.new().search(Global.grid, agent_position_grid, chest_position_grid)
	elif algoritm_options.text == "Greedy":
		result = Greedy.new().search(Global.grid, agent_position_grid, chest_position_grid)
	elif algoritm_options.text == "A*":
		result = A.new().search(Global.grid, agent_position_grid, chest_position_grid, $RewardFactor/RewardFactorValue.value)
		
	agent.move(result.path)
	
	agent.disconnect("movement_finished", Callable(self, "paint_visited"))
	agent.disconnect("movement_finished", Callable(self, "paint_expanded"))
	agent.disconnect("movement_finished", Callable(self, "create_metrics_labels"))
	agent.disconnect("movement_finished", Callable(self, "paint_path"))
	
	
	agent.connect("movement_finished", Callable(self, "paint_expanded").bind(result.nodes_expanded))
	agent.connect("movement_finished", Callable(self, "paint_visited").bind(result.nodes_visited))
	agent.connect("movement_finished", Callable(self, "paint_path").bind(result.path))
	agent.connect("movement_finished", Callable(self, "create_metrics_labels"
	).bind(result.nodes_visited.size(), result.nodes_expanded.size(), len(result.path), 
	result.path_cost, metrics_initial_pos_y, algoritm_options.text))
	

func _on_new_map_pressed() -> void:
	$NewMapDialog.visible = false
	
	Global.grid_size.x = $NewMapDialog/HBoxContainer/DimensionX.value
	Global.grid_size.y = $NewMapDialog/HBoxContainer/DimensionY.value
	var terrain_distribution = [
		$NewMapDialog/PlanoProportion.value, 
		$NewMapDialog/ArenosoProportion.value,
		$NewMapDialog/RochosoProportion.value,
		$NewMapDialog/PantanoProportion.value
	]
	
	$TileMap/Node2D.update_grid_borders()

	var generator = TerrainGenerator.new(Global.grid_size.x, Global.grid_size.y, 1.0)
	Global.grid =  generator.generate_terrain(terrain_distribution, $NewMapDialog/EmptyPlaceCheckBox.button_pressed)
	var rewards = generator.generate_rewards($NewMapDialog/RewardsAmount.value)
	
	$Chest.get_child(0).queue_free()
	for reward in $Rewards.get_children():
		reward.queue_free()
	
	Global.goal_position = rewards[0]
	Global.extra_rewards_position = rewards[1]
	
	#Instacias objetos da cena
	var chest:AnimatedSprite2D = chest_scene.instantiate()
	chest.position = Vector2(Global.goal_position.x * 16, Global.goal_position.y * 16)
	$Chest.add_child(chest)
	agent.connect("movement_finished", Callable(chest, "open"))
	
	var i = 0
	for reward_position in Global.extra_rewards_position:
		var reward = reward_scene.instantiate()
		reward.position = Vector2(reward_position.x * 16, reward_position.y * 16)
		reward.reward_id = i
		$Rewards.add_child(reward)
		i += 1

	agent.position = Vector2(0, 0)
	apply_terrain_to_tilemap()


func _on_reset_button_pressed() -> void:
	apply_terrain_to_tilemap()
	
	spawn_chest()
	spawn_rewards()
	agent.connect("reward_find", Callable(self, "remove_reward"))
	
	agent.position = initial_agent_position

func _on_window_close_requested() -> void:
	$NewMapDialog.visible = false

func _on_open_new_map_dialog_button_down() -> void:
	$NewMapDialog.popup()
	pass # Replace with function body.

func _on_clear_history_pressed() -> void:
	for node in $AlgorithmMetrics.get_children():
		node.queue_free()
	metrics_initial_pos_y = 5

func _on_option_button_item_selected(index: int) -> void:
	if algoritm_options.text in ["Greedy", "A*"]:
		$RewardFactor.visible = true
	else:
		$RewardFactor.visible = false
