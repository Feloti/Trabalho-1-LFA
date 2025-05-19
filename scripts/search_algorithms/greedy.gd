extends Node
class_name Greedy

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

func search(grid: Array, start: Vector2i, goal: Vector2i, reward_preference_factor = 0.2):
	var rows = grid.size()
	var cols = grid[0].size()
	
	var directions = [
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 0), Vector2i(-1, 0)
	]
	
	var visited = {}
	var parent = {}
	
	var nodes_visited = []
	var nodes_expanded = [start]
	
	var queue = [[start, 0]]
	
	while queue.size() > 0:
		#TODO: Sort queue
		queue.sort_custom(Callable(self, "_teste"))
		var current = queue.pop_front()[0]
		nodes_visited.append(current)
		
		if current == goal:
			break
			
		for dir in directions:
			var neighbor = current + dir
			
			if neighbor.x < 0 or neighbor.x >= cols or neighbor.y < 0 or neighbor.y >= rows:
				continue
			
			if grid[neighbor.y][neighbor.x] == -1:
				continue
			
			if not visited.has(neighbor):
				visited[neighbor] = true
				parent[neighbor] = current
				queue.push_back([neighbor, h(current, goal, reward_preference_factor)])
				nodes_expanded.append(neighbor)
	
	var path = []
	var path_cost = 0
	if visited.has(goal):
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
