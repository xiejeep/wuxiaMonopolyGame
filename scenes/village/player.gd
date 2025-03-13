extends CharacterBody2D

# 移动速度
var move_speed = 200

# 目标位置
var target_position = Vector2()

# 是否正在移动
var is_moving = false

# 移动路径
var path = []
# 当前路径点索引
var current_path_index = 0

func _ready():
	# 初始化目标位置为当前位置
	target_position = position

# 处理移动逻辑
func _physics_process(delta):
	if is_moving:
		# 计算移动方向
		var direction = (target_position - position).normalized()
		
		# 计算移动距离
		var distance_to_target = position.distance_to(target_position)
		var move_distance = move_speed * delta
		
		if move_distance >= distance_to_target:
			# 到达目标位置
			position = target_position
			
			# 检查是否还有下一个路径点
			if path.size() > 0 and current_path_index < path.size() - 1:
				# 移动到下一个路径点
				current_path_index += 1
				target_position = path[current_path_index]
			else:
				# 路径结束
				is_moving = false
				path = []
				current_path_index = 0
		else:
			# 继续移动
			velocity = direction * move_speed
			move_and_slide()

# 设置移动路径并开始移动
func move_along_path(new_path):
	if new_path.size() > 0:
		path = new_path
		current_path_index = 0
		target_position = path[current_path_index]
		is_moving = true

# 移动到指定位置（保留原有方法以兼容）
func move_to_position(pos):
	path = [pos]
	current_path_index = 0
	target_position = path[current_path_index]
	is_moving = true