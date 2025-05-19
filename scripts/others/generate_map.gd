extends Node2D
class_name TerrainGenerator

enum TerrainType {
	EMPTY = -1,
	FLAT = 1,  
	DESERT = 4,
	ROCKY = 10,
	SWAMP = 20,  
}

var thresholds = []

var map_width: int
var map_height: int
var noise_scale: float
var seed_value: int

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(width:int, height:int, scale:float, seed: int = 0) -> void:
	map_width = width
	map_height = height
	noise_scale = scale
	rng.randomize()
	

func generate_rewards(numbers_rewards: int):
	#Aleatoriza posição bau
	var goal_position:Vector2
	goal_position.x = (rng.randi() % (map_width - int(map_width/2)) + int(map_width/2))
	goal_position.y = (rng.randi() % (map_height - int(map_height/2)) + int(map_height/2))
	
	var rewards_position: Array = []
	while rewards_position.size() < numbers_rewards:
		var new_reward = Vector2(rng.randi() % map_width, rng.randi() % map_height)
		if new_reward not in rewards_position and Global.grid[new_reward.y][new_reward.x] != -1 and new_reward != goal_position and new_reward != goal_position: 
			rewards_position.append(new_reward)
	
	return [goal_position, rewards_position]

func generate_terrain(rewards_distribution: Array, empty_place: bool):
	#Calcula a proporção de cada tipo de terreno
	var sum_weights = 0.0
	for distribution in rewards_distribution:
		sum_weights += distribution
	
	var probs = []
	for distribution in rewards_distribution:
		probs.append(distribution / sum_weights)
	
	thresholds.append(probs[0])
	thresholds.append(probs[0] + probs[1])
	thresholds.append(probs[0] + probs[1] + probs[2])
	
	var terrain_matrix:Array = []
	
	# Configura o gerador de ruído
	var noise = FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_octaves = 4
	noise.frequency = 1.0 
	
	# Gera a matriz de terreno usando ruído
	for y in range(map_height):
		var row = []
		
		for x in range(map_width):
			if empty_place and rng.randf() < 0.1:
				row.append(TerrainType.EMPTY)
			else:
				var noise_value = rng.randf()
				row.append(_get_terrain_type_from_noise(noise_value))
		
		terrain_matrix.append(row)
	
	return terrain_matrix
	
func _get_terrain_type_from_noise(noise_value: float) -> int:
	if noise_value < thresholds[0]:
		return TerrainType.FLAT
	elif noise_value < thresholds[1]:
		return TerrainType.DESERT
	elif noise_value < thresholds[2]:
		return TerrainType.ROCKY
	else:
		return TerrainType.SWAMP

func _draw():
	var viewport_size = get_viewport().get_visible_rect().size
	var border_thickness = 2
	var rect = Rect2(Vector2.ZERO, viewport_size)
	draw_rect(rect, Color(1, 0, 0), false, border_thickness)
	
