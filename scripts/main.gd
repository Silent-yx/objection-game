# -*- coding: utf-8 -*-
# 主入口 — 法庭场景与核心循环
#
# 操作说明：
#   ↑/↓        选择证词
#   E          打开/关闭证据栏
#   ↑/↓ (栏内) 选择证据
#   SPACE      在证据栏打开时：举证（喊「异议」）
#   R          重开本话
extends Node

const Case01 = preload("res://data/cases/case_01.gd")

enum Phase { TESTIMONY, EVIDENCE_PICK, OBJECTION_PLAY, GAME_OVER, CLEAR }

# ------- 运行时节点 -------
var _ui_layer: CanvasLayer
var _bg: ColorRect
var _trust_bar: HBoxContainer
var _witness_label: Label
var _statement_container: VBoxContainer
var _statement_labels: Array[Label] = []
var _hint_label: Label
var _evidence_panel: Panel
var _evidence_container: VBoxContainer
var _evidence_labels: Array[Label] = []
var _evidence_desc: Label
var _flash: ColorRect
var _objection_text: Label
var _result_label: Label

# ------- 状态 -------
var _phase: int = Phase.TESTIMONY
var _statement_idx: int = 0
var _evidence_idx: int = 0
var _statements: Array
var _evidence_ids: Array
var _correct_pair: Dictionary = {}   # statement_idx -> evidence_id

# 节点准备：初始化游戏并构建 UI
func _ready() -> void:
	randomize()
	GameState.reset()
	_load_case()
	_build_ui()
	GameState.trust_changed.connect(_on_trust_changed)
	GameState.game_over.connect(_on_game_over)
	_refresh_statements()
	_refresh_evidence_list()

# 载入第一话数据
func _load_case() -> void:
	_statements = Case01.STATEMENTS
	_evidence_ids = Case01.INITIAL_EVIDENCE.duplicate()
	for eid in _evidence_ids:
		GameState.add_evidence(evidence_id=eid)
	for i in _statements.size():
		var s: Dictionary = _statements[i]
		if s.get("breakable_with", "") != "":
			_correct_pair[i] = s["breakable_with"]

# 构建整个法庭 UI（代码驱动，避免手写 tscn）
func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	add_child(_ui_layer)

	# 背景：深蓝木纹
	_bg = ColorRect.new()
	_bg.color = Color(0.07, 0.10, 0.18)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_layer.add_child(_bg)

	# 信任值条（5 颗心，右上角）
	_trust_bar = HBoxContainer.new()
	_trust_bar.position = Vector2(1280 - 240, 24)
	_trust_bar.add_theme_constant_override(name="separation", constant=8)
	_ui_layer.add_child(_trust_bar)
	for i in GameState.MAX_TRUST:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(32, 32)
		pip.color = Color(0.93, 0.27, 0.38)
		_trust_bar.add_child(pip)

	# 证人名 + 证词标题
	var header := VBoxContainer.new()
	header.position = Vector2(60, 40)
	_ui_layer.add_child(header)

	_witness_label = Label.new()
	_witness_label.text = "证人： %s" % Case01.WITNESS_NAME
	_witness_label.add_theme_font_size_override(name="font_size", font_size=22)
	_witness_label.modulate = Color(1, 0.8, 0.4)
	header.add_child(_witness_label)

	var title := Label.new()
	title.text = "「%s」" % Case01.TESTIMONY_TITLE
	title.add_theme_font_size_override(name="font_size", font_size=30)
	title.modulate = Color(1, 1, 1)
	header.add_child(title)

	# 证词容器
	_statement_container = VBoxContainer.new()
	_statement_container.position = Vector2(80, 160)
	_statement_container.custom_minimum_size = Vector2(1120, 0)
	_statement_container.add_theme_constant_override(name="separation", constant=18)
	_ui_layer.add_child(_statement_container)
	for s in _statements:
		var lbl := Label.new()
		lbl.text = "  " + str(s["text"])
		lbl.add_theme_font_size_override(name="font_size", font_size=22)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size = Vector2(1120, 0)
		_statement_container.add_child(lbl)
		_statement_labels.append(lbl)

	# 操作提示
	_hint_label = Label.new()
	_hint_label.position = Vector2(80, 600)
	_hint_label.add_theme_font_size_override(name="font_size", font_size=18)
	_hint_label.modulate = Color(0.8, 0.85, 1)
	_ui_layer.add_child(_hint_label)
	_set_hint(text="[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

	# 证据栏 Panel（默认隐藏）
	_evidence_panel = Panel.new()
	_evidence_panel.position = Vector2(280, 200)
	_evidence_panel.size = Vector2(720, 360)
	_evidence_panel.visible = false
	_ui_layer.add_child(_evidence_panel)

	var ev_title := Label.new()
	ev_title.text = "🗂  证据栏  —  选证据后按 [SPACE] 举证"
	ev_title.position = Vector2(24, 16)
	ev_title.add_theme_font_size_override(name="font_size", font_size=20)
	_evidence_panel.add_child(ev_title)

	_evidence_container = VBoxContainer.new()
	_evidence_container.position = Vector2(24, 56)
	_evidence_container.custom_minimum_size = Vector2(672, 0)
	_evidence_container.add_theme_constant_override(name="separation", constant=10)
	_evidence_panel.add_child(_evidence_container)

	_evidence_desc = Label.new()
	_evidence_desc.position = Vector2(24, 280)
	_evidence_desc.custom_minimum_size = Vector2(672, 60)
	_evidence_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_evidence_desc.modulate = Color(0.8, 0.85, 1)
	_evidence_desc.add_theme_font_size_override(name="font_size", font_size=16)
	_evidence_panel.add_child(_evidence_desc)

	# 红色闪光层
	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1, 0.1, 0.1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_flash)

	# 「异议あり！」大字
	_objection_text = Label.new()
	_objection_text.text = "異議あり！"
	_objection_text.add_theme_font_size_override(name="font_size", font_size=140)
	_objection_text.modulate = Color(1, 0.95, 0.2)
	_objection_text.position = Vector2(180, 240)
	_objection_text.scale = Vector2.ZERO
	_ui_layer.add_child(_objection_text)

	# 结果浮层
	_result_label = Label.new()
	_result_label.position = Vector2(0, 320)
	_result_label.size = Vector2(1280, 80)
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override(name="font_size", font_size=36)
	_result_label.visible = false
	_ui_layer.add_child(_result_label)

# 刷新证词高亮
func _refresh_statements() -> void:
	for i in _statement_labels.size():
		var lbl := _statement_labels[i]
		if i == _statement_idx and _phase == Phase.TESTIMONY:
			lbl.modulate = Color(1, 0.85, 0.3)
			lbl.text = "▶ " + str(_statements[i]["text"])
		else:
			lbl.modulate = Color(0.95, 0.95, 0.95)
			lbl.text = "  " + str(_statements[i]["text"])

# 刷新证据列表
func _refresh_evidence_list() -> void:
	for child in _evidence_container.get_children():
		child.queue_free()
	_evidence_labels.clear()
	for i in _evidence_ids.size():
		var ev = EvidenceDB.get_evidence(id=_evidence_ids[i])
		if ev == null:
			continue
		var lbl := Label.new()
		lbl.add_theme_font_size_override(name="font_size", font_size=18)
		lbl.text = _format_evidence_line(idx=i, name=ev.name)
		_evidence_container.add_child(lbl)
		_evidence_labels.append(lbl)
	_refresh_evidence_highlight()

# 组装证据条目文本
func _format_evidence_line(idx: int, name: String) -> String:
	var prefix := "▶ " if idx == _evidence_idx else "  "
	return "%s%s" % [prefix, name]

# 证据栏高亮 + 详情
func _refresh_evidence_highlight() -> void:
	for i in _evidence_labels.size():
		var ev = EvidenceDB.get_evidence(id=_evidence_ids[i])
		_evidence_labels[i].text = _format_evidence_line(idx=i, name=ev.name)
		_evidence_labels[i].modulate = Color(1, 0.85, 0.3) if i == _evidence_idx else Color(0.95, 0.95, 0.95)
	if _evidence_ids.size() > 0:
		var sel = EvidenceDB.get_evidence(id=_evidence_ids[_evidence_idx])
		_evidence_desc.text = "  " + sel.description

# 设置底部提示文本
func _set_hint(text: String) -> void:
	_hint_label.text = text

# 输入处理
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := event.keycode

	if key == KEY_R:
		get_tree().reload_current_scene()
		return

	match _phase:
		Phase.TESTIMONY:
			_handle_testimony_input(key=key)
		Phase.EVIDENCE_PICK:
			_handle_evidence_input(key=key)
		_:
			pass

# 证词阶段输入
func _handle_testimony_input(key: int) -> void:
	if key == KEY_UP:
		_statement_idx = (_statement_idx - 1 + _statements.size()) % _statements.size()
		_refresh_statements()
	elif key == KEY_DOWN:
		_statement_idx = (_statement_idx + 1) % _statements.size()
		_refresh_statements()
	elif key == KEY_E:
		_open_evidence_panel()

# 证据栏阶段输入
func _handle_evidence_input(key: int) -> void:
	if key == KEY_UP:
		_evidence_idx = (_evidence_idx - 1 + _evidence_ids.size()) % _evidence_ids.size()
		_refresh_evidence_highlight()
	elif key == KEY_DOWN:
		_evidence_idx = (_evidence_idx + 1) % _evidence_ids.size()
		_refresh_evidence_highlight()
	elif key == KEY_E:
		_close_evidence_panel()
	elif key == KEY_SPACE:
		_submit_evidence()

# 打开证据栏
func _open_evidence_panel() -> void:
	_phase = Phase.EVIDENCE_PICK
	_evidence_idx = 0
	_evidence_panel.visible = true
	_refresh_statements()
	_refresh_evidence_highlight()
	_set_hint(text="[↑↓] 选证据    [SPACE] 举证！   [E] 取消")

# 关闭证据栏
func _close_evidence_panel() -> void:
	_phase = Phase.TESTIMONY
	_evidence_panel.visible = false
	_refresh_statements()
	_set_hint(text="[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

# 提交举证：判定正误
func _submit_evidence() -> void:
	if _phase != Phase.EVIDENCE_PICK:
		return
	_phase = Phase.OBJECTION_PLAY
	_evidence_panel.visible = false
	var chosen_evi_id: String = _evidence_ids[_evidence_idx]
	var expected: String = _correct_pair.get(_statement_idx, "")
	if expected != "" and chosen_evi_id == expected:
		_play_objection(success=true)
	else:
		_play_objection(success=false)

# 「异议」演出 — 震屏 + 闪光 + 大字
func _play_objection(success: bool) -> void:
	# 震屏：动 CanvasLayer.offset
	var shake_tw := create_tween()
	for i in 8:
		var dx := randf_range(-18.0, 18.0)
		var dy := randf_range(-12.0, 12.0)
		shake_tw.tween_property(_ui_layer, "offset", Vector2(dx, dy), 0.04)
	shake_tw.tween_property(_ui_layer, "offset", Vector2.ZERO, 0.06)

	# 红光闪
	var flash_tw := create_tween()
	flash_tw.tween_property(_flash, "color:a", 0.55, 0.06)
	flash_tw.tween_property(_flash, "color:a", 0.0, 0.45)

	# 大字飞入
	_objection_text.scale = Vector2(0.2, 0.2)
	_objection_text.rotation = -0.4
	_objection_text.modulate.a = 1.0
	var text_tw := create_tween().set_parallel(true)
	text_tw.tween_property(_objection_text, "scale", Vector2(1.0, 1.0), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	text_tw.tween_property(_objection_text, "rotation", 0.0, 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(1.2).timeout
	var fade_tw := create_tween()
	fade_tw.tween_property(_objection_text, "modulate:a", 0.0, 0.35)
	await fade_tw.finished
	_objection_text.scale = Vector2.ZERO

	if success:
		_on_objection_success()
	else:
		_on_objection_fail()

# 举证成功 — 显示真相、剧情推进
func _on_objection_success() -> void:
	var reveal: String = str(_statements[_statement_idx].get("reveal", ""))
	_show_result(text="✓ 击破矛盾！\n证人： %s" % reveal, color=Color(0.4, 1, 0.55))
	_phase = Phase.CLEAR
	_set_hint(text="🎉 通关 demo —— 按 [R] 重开")

# 举证失败 — 扣信任值
func _on_objection_fail() -> void:
	GameState.penalize(amount=1)
	_show_result(text="✗ 错误举证！信任值 -1", color=Color(1, 0.5, 0.5))
	await get_tree().create_timer(1.4).timeout
	_result_label.visible = false
	_phase = Phase.TESTIMONY
	_refresh_statements()
	_set_hint(text="[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

# 显示结果浮层
func _show_result(text: String, color: Color) -> void:
	_result_label.text = text
	_result_label.modulate = color
	_result_label.visible = true

# 信任值变化 — 更新心条
func _on_trust_changed(new_value: int, max_value: int) -> void:
	for i in _trust_bar.get_child_count():
		var pip := _trust_bar.get_child(i) as ColorRect
		pip.color = Color(0.93, 0.27, 0.38) if i < new_value else Color(0.3, 0.3, 0.35)

# Game Over
func _on_game_over() -> void:
	_phase = Phase.GAME_OVER
	_show_result(text="⚖  GAME OVER  ⚖\n按 [R] 重开", color=Color(1, 0.4, 0.4))
	_set_hint(text="")
