extends Node2D

# 骰子最小值
var min_value = 1

# 骰子最大值
var max_value = 6

# 当前骰子点数
var current_value = 0

# 掷骰子
func roll_dice():
	# 生成随机数
	current_value = randi() % (max_value - min_value + 1) + min_value
	
	# 更新UI显示
	$"../UI/DiceResult".text = "点数: " + str(current_value)
	
	# 移动玩家
	await get_tree().create_timer(1.0).timeout
	$"../".move_player(current_value)

# 骰子按钮点击事件
func _on_dice_button_pressed():
	roll_dice()