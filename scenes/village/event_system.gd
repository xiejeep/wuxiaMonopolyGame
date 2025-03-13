extends Node

# 玩家金钱
var player_money = 0

# 事件类型枚举
enum EventType {
	MONEY_FOUND,      # 捡到钱
	BEGGAR,           # 遇到乞丐
	DOG,              # 遇到恶犬
	BLACKSMITH,       # 铁匠铺
	HOUSE,            # 民宅
	GYM,              # 武馆
	MARKET            # 市集
}

# 事件数据结构
class EventData:
	var type: int
	var title: String
	var description: String
	var options: Array
	
	func _init(event_type: int, event_title: String, event_description: String, event_options: Array = []):
		type = event_type
		title = event_title
		description = event_description
		options = event_options

# 事件列表
var events = {
	EventType.MONEY_FOUND: EventData.new(
		EventType.MONEY_FOUND,
		"发现钱币",
		"你在路边发现了10文钱！",
		[{"text": "拾取", "action": "pickup_money"}]
	),
	EventType.BEGGAR: EventData.new(
		EventType.BEGGAR,
		"遇到乞丐",
		"一位乞丐向你乞讨，是否施舍5文钱？",
		[{"text": "施舍", "action": "give_money"}, {"text": "拒绝", "action": "refuse"}]
	),
	EventType.DOG: EventData.new(
		EventType.DOG,
		"遇到恶犬",
		"一只恶犬挡住了你的去路，龇牙咧嘴地盯着你！",
		[{"text": "战斗", "action": "enter_battle"}]
	),
	EventType.BLACKSMITH: EventData.new(
		EventType.BLACKSMITH,
		"铁匠铺",
		"你来到了铁匠铺，这里可以打造装备。",
		[{"text": "进入", "action": "enter_blacksmith"}, {"text": "离开", "action": "leave"}]
	),
	EventType.HOUSE: EventData.new(
		EventType.HOUSE,
		"民宅",
		"这是一户普通的民宅。",
		[{"text": "进入", "action": "enter_house"}, {"text": "离开", "action": "leave"}]
	),
	EventType.GYM: EventData.new(
		EventType.GYM,
		"武馆",
		"这是一座武馆，里面有人在习武。",
		[{"text": "进入", "action": "enter_gym"}, {"text": "离开", "action": "leave"}]
	),
	EventType.MARKET: EventData.new(
		EventType.MARKET,
		"市集",
		"这是一个热闹的市集，有许多商贩在叫卖。",
		[{"text": "进入", "action": "enter_market"}, {"text": "离开", "action": "leave"}]
	)
}

# 事件计数器，用于控制每轮触发的事件数量
var event_counters = {
	EventType.HOUSE: 0,
	EventType.BLACKSMITH: 0,
	EventType.DOG: 0,
	EventType.GYM: 0,
	EventType.MARKET: 0
}

# 事件限制，每轮最多触发的事件数量
var event_limits = {
	EventType.HOUSE: 3,
	EventType.BLACKSMITH: 1,
	EventType.DOG: 1,
	EventType.GYM: 1,
	EventType.MARKET: 1
}

# 路径点与设施的映射关系
var point_facility_map = {
	# 铁匠铺附近的路径点
	4: EventType.BLACKSMITH,
	5: EventType.BLACKSMITH,
	24: EventType.BLACKSMITH,
	25: EventType.BLACKSMITH,
	
	# 武馆附近的路径点
	6: EventType.GYM,
	7: EventType.GYM,
	26: EventType.GYM,
	27: EventType.GYM,
	
	# 市集附近的路径点
	8: EventType.MARKET,
	9: EventType.MARKET,
	28: EventType.MARKET,
	29: EventType.MARKET,
	
	# 民宅附近的路径点
	24: EventType.HOUSE,
	25: EventType.HOUSE,
	26: EventType.HOUSE,
	27: EventType.HOUSE,
	28: EventType.HOUSE,
	29: EventType.HOUSE
}

# 低概率事件的触发概率（百分比）
var low_probability_event_chance = 20

# 重置事件计数器
func reset_event_counters():
	for event_type in event_counters.keys():
		event_counters[event_type] = 0

# 随机触发事件
func trigger_random_event():
	# 获取当前玩家所在的路径点索引
	var current_point_index = $"../".current_player_position + 1  # +1 因为路径点从1开始编号
	
	# 检查当前路径点是否与特定设施关联
	if point_facility_map.has(current_point_index):
		# 获取关联的设施类型
		var facility_event_type = point_facility_map[current_point_index]
		
		# 检查该设施事件是否已达到限制
		if event_counters[facility_event_type] < event_limits[facility_event_type]:
			# 更新事件计数器
			event_counters[facility_event_type] += 1
			
			# 触发设施事件
			show_event_ui(events[facility_event_type])
			return
	
	# 如果没有触发设施事件，则有低概率触发随机基础事件
	if randi() % 100 < low_probability_event_chance:
		var basic_events = [EventType.MONEY_FOUND, EventType.BEGGAR, EventType.DOG]
		var random_basic_event = basic_events[randi() % basic_events.size()]
		show_event_ui(events[random_basic_event])
		return
	
	# 如果没有触发任何事件，显示一个简单的通知
	show_notification("这里什么也没有发生。")

# 显示事件UI
func show_event_ui(event_data: EventData):
	# 获取事件UI节点
	var event_ui = $"../UI/EventPanel"
	
	# 设置事件标题和描述
	event_ui.get_node("Title").text = event_data.title
	event_ui.get_node("Description").text = event_data.description
	
	# 清除旧的选项按钮
	var options_container = event_ui.get_node("Options")
	for child in options_container.get_children():
		child.queue_free()
	
	# 添加新的选项按钮
	for i in range(event_data.options.size()):
		var option = event_data.options[i]
		var button = Button.new()
		button.text = option.text
		button.connect("pressed", Callable(self, "_on_option_selected").bind(event_data.type, option.action))
		options_container.add_child(button)
	
	# 显示事件面板
	event_ui.visible = true

# 处理选项选择
func _on_option_selected(event_type: int, action: String):
	# 隐藏事件面板
	$"../UI/EventPanel".visible = false
	
	# 根据选择的动作执行相应的处理
	match action:
		"pickup_money":
			# 捡到10文钱
			player_money += 10
			update_money_display()
			show_notification("获得了10文钱！")
		
		"give_money":
			# 施舍5文钱给乞丐
			if player_money >= 5:
				player_money -= 5
				update_money_display()
				show_notification("你施舍了5文钱给乞丐。")
			else:
				show_notification("你没有足够的钱！")
		
		"refuse":
			# 拒绝乞丐
			show_notification("你拒绝了乞丐的请求。")
		
		"enter_battle":
			# 进入战斗场景（暂时为空）
			show_notification("战斗系统尚未实现。")
		
		"enter_blacksmith":
			# 进入铁匠铺场景（暂时为空）
			show_notification("铁匠铺场景尚未实现。")
		
		"enter_house":
			# 进入民宅场景（暂时为空）
			show_notification("民宅场景尚未实现。")
		
		"enter_gym":
			# 进入武馆场景（暂时为空）
			show_notification("武馆场景尚未实现。")
		
		"enter_market":
			# 进入市集场景（暂时为空）
			show_notification("市集场景尚未实现。")
		
		"leave":
			# 离开，不做任何处理
			pass

# 更新金钱显示
func update_money_display():
	$"../UI/MoneyLabel".text = "金钱: " + str(player_money) + "文"

# 显示通知
func show_notification(message: String):
	var notification = $"../UI/Notification"
	notification.text = message
	notification.visible = true
	
	# 2秒后自动隐藏通知
	await get_tree().create_timer(2.0).timeout
	notification.visible = false