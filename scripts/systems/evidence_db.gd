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
	var detail_after: String   # 真相揭示后翻转的细节（为空则永不翻转）

	func _init(p_id: String, p_name: String, p_desc: String, p_detail: String = "", p_detail_after: String = "") -> void:
		id = p_id
		display_name = p_name
		description = p_desc
		detail = p_detail
		detail_after = p_detail_after

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

	# Stage 2（Christine 反水）选中核心证词时入栏；S3 字迹比对的叙事氛围
	_register(
		"christine_testimony",
		"Christine 的控方证词笔录",
		"庭审记录：被告于二十二时十分返家，衣袖带血，自陈杀人。",
		"笔录措辞冷静、滴水不漏，无一处自相矛盾——反常地完美。"
	)
	# Stage 2 叙事支撑（注册保留，不入栏、不作击破证据）
	_register(
		"marriage_record_de",
		"德国婚姻登记副本",
		"Christine（婚前名 Romaine）在德国与他人登记结婚的副本（1945 年）。",
		"该婚姻在英国法律下从未解除——意味着 Christine 与 Leonard 的「婚姻」可能无效。"
	)
	# Stage 3（神秘信件）由神秘女人卖给 Robarts，击破 Christine 的工具；
	# detail = S3 伪胜利时的语义；detail_after = S4 真相揭示后翻转的语义。
	_register(
		"christine_letters",
		"一叠署名 Christine 的私信",
		"写给「Max」的情书，字迹娟秀。",
		"信里盼着 Leonard 被送上绞架、好与情人 Max 远走高飞——这分明是个心怀怨毒、说谎成性的女人。",
		"真相之后再读：这些信是 Christine 亲手伪造、特意留下破绽卖给你的。她把自己演成一个可恨的毒妇，就为了让你『揭穿』她、把陪审团推向无罪——你不是赢了，你是被她当成了脱罪的工具。"
	)

# 注册一条证据
func _register(id: String, display_name: String, description: String, detail: String = "", detail_after: String = "") -> void:
	_db[id] = Evidence.new(id, display_name, description, detail, detail_after)

# 按 ID 取证据
func get_evidence(id: String) -> Evidence:
	return _db.get(id)

# 取所有证据 ID
func all_ids() -> Array:
	return _db.keys()
