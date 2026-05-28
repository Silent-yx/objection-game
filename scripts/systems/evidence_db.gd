# -*- coding: utf-8 -*-
# 证据数据库 — 第一话《控方证人》改编版
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
	var detail: String

	func _init(p_id: String, p_name: String, p_desc: String, p_detail: String = "") -> void:
		id = p_id
		display_name = p_name
		description = p_desc
		detail = p_detail

	func has_detail() -> bool:
		return detail != ""

var _db: Dictionary = {}

# 节点准备完毕时注册案件所有证据
func _ready() -> void:
	# Stage 0 (律师事务所) 完成后解锁
	_register(
		"police_report",
		"警方初步报告",
		"伦敦警察厅对 Emily French 案的初步报告（六月四日清晨出具）。",
		"死者头部遭钝器击打致死，案发时间约六月三日晚九点半至十点之间。现场无强行闯入迹象。"
	)
	_register(
		"will_amendment",
		"遗嘱修改记录",
		"Emily French 在死亡前两周修改了遗嘱。",
		"原遗嘱中管家 Janet MacKenzie 是主要继承人。修改后 Janet 仅得一千英镑，Leonard Vole 获得八万英镑。"
	)
	_register(
		"leonard_statement",
		"Leonard 自述",
		"Leonard Vole 的事件经过陈述（律师事务所记录）。",
		"自称六月三日全晚在家与妻子 Romaine 共度，九点至十一点未离开公寓一步。"
	)

	# Stage 1 (管家证词) 进行中解锁
	_register(
		"doctor_note",
		"听力诊断书",
		"圣玛丽医院出具的 Janet MacKenzie 听力诊断书（去年三月）。",
		"双耳重度感音性听力损失，对四米以外的对话与脚步声基本无法辨识。建议患者佩戴助听器。"
	)
	_register(
		"emily_letter",
		"Emily 寄给妹妹的信",
		"Emily French 案发前十日写给妹妹的家信。",
		"信中提到：「Vole 先生帮我整理了客厅那个旧抽屉，里头乱七八糟堆了二十年。我请他过来弄。」"
	)

	# 未来 Stage 用（先注册占位，下一批次启用）
	_register(
		"marriage_record_de",
		"德国婚姻登记副本",
		"Romaine Vole 在德国与他人登记结婚的副本（1945 年）。",
		"该婚姻在英国法律下从未解除——意味着 Romaine 与 Leonard 的「婚姻」可能无效。"
	)
	_register(
		"anonymous_letters",
		"匿名信件包",
		"一位神秘女士交给 Robarts 的信件包，内含 Romaine 写给 Max 的信若干。",
		"信中 Romaine 写道：「······我恨他，Max，我要让他付出代价。请等我。」"
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
