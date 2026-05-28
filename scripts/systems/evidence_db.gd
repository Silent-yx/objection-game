# -*- coding: utf-8 -*-
# 证据数据库：所有证据的元数据存放在这里
#
# 每条证据有两层信息：
#   description — 一眼可见的概要（默认显示）
#   detail      — 玩家按 D「调查」后才看到的细节（含关键暗示）
extends Node

# 证据数据结构
class Evidence:
	var id: String
	var display_name: String
	var description: String
	var detail: String   # 可空。空时表示该证据无更多细节

	func _init(p_id: String, p_name: String, p_desc: String, p_detail: String = "") -> void:
		id = p_id
		display_name = p_name
		description = p_desc
		detail = p_detail

	# 判断这件证据是否有「深度详情」可调查
	func has_detail() -> bool:
		return detail != ""

var _db: Dictionary = {}

# 节点准备完毕时注册第一话所有证据
func _ready() -> void:
	# 第一话《绿色圆圈案》— 食堂模拟法庭
	_register(
		"cafeteria_menu",
		"宫保鸡丁菜单照",
		"食堂档口的菜品公示牌照片：「宫保鸡丁 ¥8」",
		"放大看价签下方小字 —— 「中辣 · 含干辣椒」。这是宫保鸡丁的标准配料。"
	)
	_register(
		"seat_photo",
		"排队监控照",
		"食堂入口监控截图：易南星端着餐盘经过白小研座位。",
		"放大画面 —— 易南星**双手都端着自己的盘子**，没有任何空手伸向受害者方向的动作。"
	)
	_register(
		"lunch_receipt",
		"白小研的饭票小票",
		"周阿姨递交的小票，时间 12:14:33。",
		"小票上明确印着：「**宫保鸡丁 · 中辣 · ¥8**」。"
	)
	_register(
		"redbook_post",
		"白小研一周前的小红书",
		"截图标题：「南方菜好神奇 😭」（发布于上周三）",
		"正文：「**每次都吃到绿色小怪兽**，到底是什么啊……」—— 一周前他就遇到过同样的东西。"
	)
	_register(
		"chili_specimen",
		"干辣椒标本",
		"周阿姨从厨房拿来的一颗完整干辣椒，作为物证。",
		"周阿姨：「这是配宫保鸡丁的标配，整袋整袋买来的，谁会单独投放？」"
	)

# 注册一条证据
func _register(id: String, display_name: String, description: String, detail: String = "") -> void:
	_db[id] = Evidence.new(id, display_name, description, detail)

# 按 ID 取证据
func get_evidence(id: String) -> Evidence:
	return _db.get(id)

# 取所有证据 ID
func all_ids() -> Array:
	return _db.keys()
