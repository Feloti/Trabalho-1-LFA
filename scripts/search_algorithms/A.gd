class_name A

var rewards_search = Global.extra_rewards_position.duplicate()
var REWARD_VALUE = 100.0

func dist_manhattan(a, b):
	return (abs(a.x - b.x) + abs(a.y - b.y))
	
func h(neighbor, goal, preference_factor):
	var reward_potential = 0
	if preference_factor > 0:
		for reward in rewards_search:
			var dist_reward = dist_manhattan(neighbor, reward)
			if dist_reward == 0:
				reward_potential += REWARD_VALUE
			else:
				reward_potential += REWARD_VALUE / dist_reward
	
	return dist_manhattan(neighbor, goal) - preference_factor * reward_potential

func search(grid:Array, start:Vector2, goal:Vector2, reward_preference_factor = 0.2):
	var rows = grid.size()
	var cols = grid[0].size()
	
	var directions = [
		Vector2(0, 1), Vector2(0, -1),
		Vector2(1, 0), Vector2(-1, 0)
	]
	
	var queue = []
	var visited = {}
	var parent = {}
	var g_score = {}
	var f_score = {}
	
	var nodes_visited = []
	var nodes_expanded = [start]
	
	g_score[start] = 0.0
	f_score[start] = h(start, goal, reward_preference_factor)
	queue.append(start)
	
	var aux_reward_positions = []
	while queue.size() > 0:
		var current = queue[0]
		for node in queue:
			if f_score.get(node, INF) < f_score.get(current, INF):
				current = node
		nodes_visited.append(current)
		queue.erase(current)
		
		if current in rewards_search:
			rewards_search.erase(current)
			
		if current == goal:
			break
			
		visited[current] = true
		
		for dir in directions:
			var neighbor = current + dir
			
			if neighbor.x < 0 or neighbor.x >= cols or neighbor.y < 0 or neighbor.y >= rows:
				continue
			if grid[neighbor.y][neighbor.x] == -1:
				continue
			if visited.has(neighbor):
				continue
			
			var reward_bonus = 0.0
			if neighbor in Global.extra_rewards_position:
				reward_bonus = REWARD_VALUE * reward_preference_factor 
			var tentative_g = g_score[current] + grid[neighbor.y][neighbor.x] - reward_bonus
			
			if not g_score.has(neighbor) or tentative_g < g_score[neighbor]:

				parent[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + h(neighbor, goal, reward_preference_factor)
				
				if not queue.has(neighbor):
					queue.append(neighbor)
					nodes_expanded.append(neighbor)
					
	var path = []
	var path_cost = 0
	if parent.has(goal) or start == goal:
		var step = goal
		while step != start:
			path.push_front(step)
			path_cost += grid[step.y][step.x]
			step = parent[step]
		path.push_front(start)
		
	return {
		"path": path,
		"path_cost": path_cost,
		"nodes_visited": nodes_visited,
		"nodes_expanded": nodes_expanded
	}
