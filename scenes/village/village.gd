extends Node2D

# 路径点数组
var path_points = []

# 当前玩家位置的索引
var current_player_position = 0

func _ready():
	# 获取所有路径点并存储到数组中
	for i in range(1, 50):
		var point = get_node("PathPoints/Point" + str(i))
		path_points.append(point)
	
	# 设置玩家初始位置
	$Player.position = path_points[current_player_position].position
	
	# 初始化事件系统
	$EventSystem.update_money_display()
	# 初始化事件计数器
	$EventSystem.reset_event_counters()

# 移动玩家到指定的路径点
func move_player(steps):
	# 计算新位置
	var new_position = (current_player_position + steps) % path_points.size()
	
	# 生成从当前位置到目标位置的路径
	var path_to_follow = []
	
	# 如果步数为正，向前移动
	if steps > 0:
		for i in range(1, steps + 1):
			var path_index = (current_player_position + i) % path_points.size()
			path_to_follow.append(path_points[path_index].position)
	# 如果步数为负，向后移动
	elif steps < 0:
		for i in range(1, abs(steps) + 1):
			var path_index = (current_player_position - i) % path_points.size()
			path_to_follow.append(path_points[path_index].position)
	
	# 更新当前位置
	current_player_position = new_position
	
	# 让玩家沿着路径移动
	$Player.move_along_path(path_to_follow)
	
	# 等待玩家移动完成后触发事件
	await get_tree().create_timer(0.5).timeout
	await _check_player_movement_complete()
	
	# 如果玩家回到起点，重置事件计数器
	if current_player_position == 0:
		$EventSystem.reset_event_counters()
		print("事件计数器已重置")

# 检查玩家是否完成移动，如果完成则触发事件
func _check_player_movement_complete():
	# 等待玩家停止移动
	while $Player.is_moving:
		await get_tree().process_frame
	
	# 玩家移动完成，随机触发事件
	$EventSystem.trigger_random_event()