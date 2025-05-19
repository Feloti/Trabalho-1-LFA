extends Node

class_name DFS

func search(grid: Array, start: Vector2i, goal: Vector2i):
	var rows = grid.size()
	var cols = grid[0].size()
	
	var directions = [
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 0), Vector2i(-1, 0)
	]
	directions.reverse()
	var visited = {}
	var parent = {}
	
	var nodes_visited = []
	var nodes_expanded = [start]
	
	var stack = [start]
	visited[start] = true
	
	while stack.size() > 0:
		var current = stack.pop_back()
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
				stack.push_back(neighbor)
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
