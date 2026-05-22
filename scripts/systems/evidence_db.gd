# -*- coding: utf-8 -*-
# 证据数据库：所有证据的元数据存放在这里
extends Node

# 证据数据结构
class Evidence:
	var id: String
	var name: String
	var description: String

	func _init(p_id: String, p_name: String, p_desc: String) -> void:
		id = p_id
		name = p_name
		description = p_desc

var _db: Dictionary = {}

# 节点准备完毕时注册示例证据
func _ready() -> void:
	_register(id="tv_outage_notice", name="电视台维修通告", desc="证明案发当晚 22:00-02:00 该频道停播。")
	_register(id="victim_watch", name="被害人腕表", desc="时针停在 23:45，玻璃表面有裂痕。")
	_register(id="footprint_photo", name="现场脚印照片", desc="后院的男士 42 码鞋印，方向朝向围墙。")

# 注册一条证据
func _register(id: String, name: String, desc: String) -> void:
	_db[id] = Evidence.new(p_id=id, p_name=name, p_desc=desc)

# 按 ID 取证据
func get_evidence(id: String) -> Evidence:
	return _db.get(id)

# 取所有证据 ID
func all_ids() -> Array:
	return _db.keys()
