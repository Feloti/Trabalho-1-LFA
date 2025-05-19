class_name BFS

func search(grid:Array, start:Vector2, goal:Vector2):
	var rows = grid.size()
	var cols = grid[0].size()
	
	var directions = [
		Vector2(0, 1), Vector2(0, -1),
		Vector2(1, 0), Vector2(-1, 0)
	]
	
	var queue = []
	var visited = {}
	var parent = {}
	
	var nodes_visited = []
	var nodes_expanded = [start]
	
	queue.push_back(start)
	visited[start] = true
	
	print(start)
	while queue.size() > 0:
		var current = queue.pop_front()
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
				queue.push_back(neighbor)
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
