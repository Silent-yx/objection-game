# -*- coding: utf-8 -*-
# 主入口 — 法庭场景与核心循环
#
# 操作说明：
#   ↑/↓        选择证词
#   E          打开/关闭证据栏
#   ↑/↓ (栏内) 选择证据
#   D  (栏内)  调查证据 → 展开/收起「深度详情」
#   SPACE      在证据栏打开时：举证（喊「异议」）
#   R          重开本话
extends Node

const Case01 = preload("res://data/cases/case_01.gd")

# ---- 美术资源 ----
const BG_CAFETERIA      = preload("res://assets/images/backgrounds/cafeteria_courtroom.png")
const FACE_NORMAL       = preload("res://assets/images/characters/yi_nanxing/normal.png")
const FACE_NERVOUS      = preload("res://assets/images/characters/yi_nanxing/nervous.png")
const FACE_SHOCKED      = preload("res://assets/images/characters/yi_nanxing/shocked.png")
const FACE_POINTING     = preload("res://assets/images/characters/yi_nanxing/pointing.png")
const FACE_THINKING     = preload("res://assets/images/characters/yi_nanxing/thinking.png")
const OBJECTION_IMG     = preload("res://assets/images/effects/objection.png")

enum Phase { TESTIMONY, EVIDENCE_PICK, OBJECTION_PLAY, GAME_OVER, CLEAR }

# ------- 运行时节点 -------
var _ui_layer: CanvasLayer
var _bg: TextureRect
var _protagonist: TextureRect
var _trust_bar: HBoxContainer
var _witness_label: Label
var _statement_container: VBoxContainer
var _statement_labels: Array[Label] = []
var _hint_label: Label
var _evidence_panel: Panel
var _evidence_container: VBoxContainer
var _evidence_labels: Array[Label] = []
var _evidence_desc: Label
var _evidence_detail_panel: Panel
var _evidence_detail_label: Label
var _toast_label: Label
var _flash: ColorRect
var _objection_sprite: TextureRect
var _result_label: Label

# ------- 状态 -------
var _phase: int = Phase.TESTIMONY
var _statement_idx: int = 0
var _evidence_idx: int = 0
var _statements: Array
var _evidence_ids: Array
var _correct_pair: Dictionary = {}      # statement_idx -> evidence_id
var _stages_triggered: Array = []       # 已触发过追加证据的证词索引集合
var _detail_open: bool = false          # 深度详情是否展开

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
	# 初始证词索引 0 也可能触发证据追加
	_check_stage_additions(_statement_idx)

# 载入第一话数据
func _load_case() -> void:
	_statements = Case01.STATEMENTS
	_evidence_ids = Case01.INITIAL_EVIDENCE.duplicate()
	for eid in _evidence_ids:
		GameState.add_evidence(eid)
	for i in _statements.size():
		var s: Dictionary = _statements[i]
		if s.get("breakable_with", "") != "":
			_correct_pair[i] = s["breakable_with"]

# 构建整个法庭 UI（代码驱动，避免手写 tscn）
func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	add_child(_ui_layer)

	# 1) 背景图：食堂模拟法庭
	_bg = TextureRect.new()
	_bg.texture = BG_CAFETERIA
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_bg)

	# 2) 半透明遮罩，让文字更易读
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.35)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(overlay)

	# 3) 主角立绘（右侧）
	_protagonist = TextureRect.new()
	_protagonist.texture = FACE_NORMAL
	_protagonist.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_protagonist.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_protagonist.position = Vector2(880, 170)
	_protagonist.size = Vector2(380, 540)
	_protagonist.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_protagonist)

	# 4) 信任值条（左上）
	_trust_bar = HBoxContainer.new()
	_trust_bar.position = Vector2(60, 24)
	_trust_bar.add_theme_constant_override("separation", 8)
	_ui_layer.add_child(_trust_bar)
	for i in GameState.MAX_TRUST:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(32, 32)
		pip.color = Color(0.93, 0.27, 0.38)
		_trust_bar.add_child(pip)

	# 5) 证人名 + 证词标题
	var header := VBoxContainer.new()
	header.position = Vector2(60, 80)
	_ui_layer.add_child(header)

	_witness_label = Label.new()
	_witness_label.text = "检方： %s" % Case01.WITNESS_NAME
	_witness_label.add_theme_font_size_override("font_size", 22)
	_witness_label.modulate = Color(1, 0.85, 0.4)
	header.add_child(_witness_label)

	var title := Label.new()
	title.text = "「%s」" % Case01.TESTIMONY_TITLE
	title.add_theme_font_size_override("font_size", 30)
	title.modulate = Color(1, 1, 1)
	header.add_child(title)

	# 6) 证词容器
	_statement_container = VBoxContainer.new()
	_statement_container.position = Vector2(60, 200)
	_statement_container.custom_minimum_size = Vector2(800, 0)
	_statement_container.add_theme_constant_override("separation", 14)
	_ui_layer.add_child(_statement_container)
	for s in _statements:
		var lbl := Label.new()
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size = Vector2(800, 0)
		_statement_container.add_child(lbl)
		_statement_labels.append(lbl)

	# 7) 操作提示
	_hint_label = Label.new()
	_hint_label.position = Vector2(60, 660)
	_hint_label.add_theme_font_size_override("font_size", 18)
	_hint_label.modulate = Color(0.85, 0.9, 1)
	_ui_layer.add_child(_hint_label)
	_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

	# 8) 证据栏 Panel
	_evidence_panel = Panel.new()
	_evidence_panel.position = Vector2(200, 180)
	_evidence_panel.size = Vector2(880, 400)
	_evidence_panel.visible = false
	_ui_layer.add_child(_evidence_panel)

	var ev_title := Label.new()
	ev_title.text = "🗂  证据栏  —  [D] 调查证物    [SPACE] 举证"
	ev_title.position = Vector2(24, 16)
	ev_title.add_theme_font_size_override("font_size", 20)
	_evidence_panel.add_child(ev_title)

	_evidence_container = VBoxContainer.new()
	_evidence_container.position = Vector2(24, 60)
	_evidence_container.custom_minimum_size = Vector2(832, 0)
	_evidence_container.add_theme_constant_override("separation", 10)
	_evidence_panel.add_child(_evidence_container)

	_evidence_desc = Label.new()
	_evidence_desc.position = Vector2(24, 300)
	_evidence_desc.custom_minimum_size = Vector2(832, 80)
	_evidence_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_evidence_desc.modulate = Color(0.85, 0.9, 1)
	_evidence_desc.add_theme_font_size_override("font_size", 16)
	_evidence_panel.add_child(_evidence_desc)

	# 9) 深度详情浮层（默认隐藏）
	_evidence_detail_panel = Panel.new()
	_evidence_detail_panel.position = Vector2(120, 100)
	_evidence_detail_panel.size = Vector2(1040, 520)
	_evidence_detail_panel.visible = false
	_ui_layer.add_child(_evidence_detail_panel)

	var dt_title := Label.new()
	dt_title.text = "🔍  调查证物  —  再按 [D] 关闭"
	dt_title.position = Vector2(24, 16)
	dt_title.add_theme_font_size_override("font_size", 22)
	dt_title.modulate = Color(1, 0.95, 0.5)
	_evidence_detail_panel.add_child(dt_title)

	_evidence_detail_label = Label.new()
	_evidence_detail_label.position = Vector2(40, 80)
	_evidence_detail_label.size = Vector2(960, 420)
	_evidence_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_evidence_detail_label.add_theme_font_size_override("font_size", 22)
	_evidence_detail_label.modulate = Color(1, 1, 1)
	_evidence_detail_panel.add_child(_evidence_detail_label)

	# 10) Toast（屏幕顶部短暂提示）
	_toast_label = Label.new()
	_toast_label.position = Vector2(0, 140)
	_toast_label.size = Vector2(1280, 40)
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.add_theme_font_size_override("font_size", 22)
	_toast_label.modulate = Color(1, 0.9, 0.4, 0)
	_ui_layer.add_child(_toast_label)

	# 11) 红色闪光层
	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1, 0.1, 0.1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_flash)

	# 12) 「異議あり！」大字图
	_objection_sprite = TextureRect.new()
	_objection_sprite.texture = OBJECTION_IMG
	_objection_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_objection_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_objection_sprite.size = Vector2(900, 600)
	_objection_sprite.position = Vector2(190, 60)
	_objection_sprite.pivot_offset = Vector2(450, 300)
	_objection_sprite.scale = Vector2.ZERO
	_objection_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_objection_sprite)

	# 13) 结果浮层
	_result_label = Label.new()
	_result_label.position = Vector2(0, 320)
	_result_label.size = Vector2(1280, 80)
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 36)
	_result_label.visible = false
	_ui_layer.add_child(_result_label)

# 设置主角表情立绘
func _set_face(face: Texture2D) -> void:
	_protagonist.texture = face

# 组装证词文本（含说话人前缀）
func _format_statement(idx: int) -> String:
	var s: Dictionary = _statements[idx]
	var prefix := "▶ " if idx == _statement_idx and _phase == Phase.TESTIMONY else "  "
	var speaker = str(s.get("speaker", ""))
	if speaker == "":
		return "%s%s" % [prefix, str(s["text"])]
	return "%s[%s] %s" % [prefix, speaker, str(s["text"])]

# 刷新证词高亮
func _refresh_statements() -> void:
	for i in _statement_labels.size():
		var lbl := _statement_labels[i]
		lbl.text = _format_statement(i)
		if i == _statement_idx and _phase == Phase.TESTIMONY:
			lbl.modulate = Color(1, 0.85, 0.3)
		else:
			lbl.modulate = Color(0.95, 0.95, 0.95)

# 刷新证据列表
func _refresh_evidence_list() -> void:
	for child in _evidence_container.get_children():
		child.queue_free()
	_evidence_labels.clear()
	for i in _evidence_ids.size():
		var ev = EvidenceDB.get_evidence(_evidence_ids[i])
		if ev == null:
			continue
		var lbl := Label.new()
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.text = _format_evidence_line(i, ev.display_name, ev.has_detail())
		_evidence_container.add_child(lbl)
		_evidence_labels.append(lbl)
	_refresh_evidence_highlight()

# 组装证据条目文本（含可调查角标）
func _format_evidence_line(idx: int, display_name: String, has_detail: bool) -> String:
	var prefix := "▶ " if idx == _evidence_idx else "  "
	var detail_mark := "  🔍" if has_detail else ""
	return "%s%s%s" % [prefix, display_name, detail_mark]

# 证据栏高亮 + 详情
func _refresh_evidence_highlight() -> void:
	for i in _evidence_labels.size():
		var ev = EvidenceDB.get_evidence(_evidence_ids[i])
		_evidence_labels[i].text = _format_evidence_line(i, ev.display_name, ev.has_detail())
		_evidence_labels[i].modulate = Color(1, 0.85, 0.3) if i == _evidence_idx else Color(0.95, 0.95, 0.95)
	if _evidence_ids.size() > 0:
		var sel = EvidenceDB.get_evidence(_evidence_ids[_evidence_idx])
		_evidence_desc.text = "  " + sel.description
		# 切换选中时关闭已展开的深度详情
		if _detail_open:
			_close_detail()

# 设置底部提示文本
func _set_hint(text: String) -> void:
	_hint_label.text = text

# 输入处理
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: int = event.keycode

	if key == KEY_R:
		get_tree().reload_current_scene()
		return

	match _phase:
		Phase.TESTIMONY:
			_handle_testimony_input(key)
		Phase.EVIDENCE_PICK:
			_handle_evidence_input(key)
		_:
			pass

# 证词阶段输入
func _handle_testimony_input(key: int) -> void:
	if key == KEY_UP:
		_statement_idx = (_statement_idx - 1 + _statements.size()) % _statements.size()
		_refresh_statements()
		_check_stage_additions(_statement_idx)
	elif key == KEY_DOWN:
		_statement_idx = (_statement_idx + 1) % _statements.size()
		_refresh_statements()
		_check_stage_additions(_statement_idx)
	elif key == KEY_E:
		_open_evidence_panel()

# 证据栏阶段输入
func _handle_evidence_input(key: int) -> void:
	if key == KEY_D:
		_toggle_evidence_detail()
		return
	# 深度详情打开时，方向键/空格/E 都先关闭它
	if _detail_open:
		_close_detail()
		return
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

# 切换「调查证物」深度详情面板
func _toggle_evidence_detail() -> void:
	if _detail_open:
		_close_detail()
	else:
		_open_detail()

# 打开深度详情
func _open_detail() -> void:
	if _evidence_ids.size() == 0:
		return
	var ev = EvidenceDB.get_evidence(_evidence_ids[_evidence_idx])
	if ev == null:
		return
	if ev.has_detail():
		_evidence_detail_label.text = "「%s」\n\n%s" % [ev.display_name, ev.detail]
		_evidence_detail_label.modulate = Color(1, 1, 1)
	else:
		_evidence_detail_label.text = "「%s」\n\n暂无更多细节可调查。" % ev.display_name
		_evidence_detail_label.modulate = Color(0.7, 0.7, 0.75)
	_evidence_detail_panel.visible = true
	_detail_open = true
	_set_hint("[D] 关闭调查面板")

# 关闭深度详情
func _close_detail() -> void:
	_evidence_detail_panel.visible = false
	_detail_open = false
	_set_hint("[↑↓] 选证据    [D] 调查证物    [SPACE] 举证！   [E] 取消")

# 打开证据栏
func _open_evidence_panel() -> void:
	_phase = Phase.EVIDENCE_PICK
	_evidence_idx = 0
	_evidence_panel.visible = true
	_set_face(FACE_THINKING)
	_refresh_statements()
	_refresh_evidence_highlight()
	_set_hint("[↑↓] 选证据    [D] 调查证物    [SPACE] 举证！   [E] 取消")

# 关闭证据栏
func _close_evidence_panel() -> void:
	_phase = Phase.TESTIMONY
	_evidence_panel.visible = false
	_close_detail()
	_set_face(FACE_NORMAL)
	_refresh_statements()
	_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

# 检查 STAGE_ADDITIONS — 选中证词时自动追加新证据
func _check_stage_additions(idx: int) -> void:
	if idx in _stages_triggered:
		return
	var to_add = Case01.STAGE_ADDITIONS.get(idx, [])
	if to_add.is_empty():
		return
	_stages_triggered.append(idx)
	for eid in to_add:
		_add_evidence_runtime(eid)

# 运行时追加证据 — 加入物品栏 + Toast 提示
func _add_evidence_runtime(eid: String) -> void:
	if eid in _evidence_ids:
		return
	var ev = EvidenceDB.get_evidence(eid)
	if ev == null:
		return
	_evidence_ids.append(eid)
	GameState.add_evidence(eid)
	_refresh_evidence_list()
	_show_toast("📎 新证据加入物品栏：%s" % ev.display_name)

# 顶部 Toast 浮现一段时间后淡出
func _show_toast(text: String) -> void:
	_toast_label.text = text
	var tw := create_tween()
	tw.tween_property(_toast_label, "modulate:a", 1.0, 0.25)
	tw.tween_interval(2.0)
	tw.tween_property(_toast_label, "modulate:a", 0.0, 0.4)

# 提交举证：判定正误
func _submit_evidence() -> void:
	if _phase != Phase.EVIDENCE_PICK:
		return
	_phase = Phase.OBJECTION_PLAY
	_evidence_panel.visible = false
	_close_detail()
	_set_face(FACE_POINTING)
	var chosen_evi_id: String = _evidence_ids[_evidence_idx]
	var expected: String = _correct_pair.get(_statement_idx, "")
	if expected != "" and chosen_evi_id == expected:
		_play_objection(true)
	else:
		_play_objection(false)

# 「异议」演出 — 震屏 + 闪光 + 大字
func _play_objection(success: bool) -> void:
	# 震屏
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
	_objection_sprite.scale = Vector2(0.2, 0.2)
	_objection_sprite.rotation = -0.4
	_objection_sprite.modulate.a = 1.0
	var text_tw := create_tween().set_parallel(true)
	text_tw.tween_property(_objection_sprite, "scale", Vector2(1.0, 1.0), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	text_tw.tween_property(_objection_sprite, "rotation", 0.0, 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(1.2).timeout
	var fade_tw := create_tween()
	fade_tw.tween_property(_objection_sprite, "modulate:a", 0.0, 0.35)
	await fade_tw.finished
	_objection_sprite.scale = Vector2.ZERO

	if success:
		_on_objection_success()
	else:
		_on_objection_fail()

# 举证成功 — 显示真相、剧情推进
func _on_objection_success() -> void:
	var reveal: String = str(_statements[_statement_idx].get("reveal", ""))
	_show_result("✓ 击破矛盾！\n%s" % reveal, Color(0.4, 1, 0.55))
	_phase = Phase.CLEAR
	_set_face(FACE_POINTING)
	_set_hint("🎉 通关 demo —— 按 [R] 重开")

# 举证失败 — 扣信任值
func _on_objection_fail() -> void:
	GameState.penalize(1)
	_set_face(FACE_SHOCKED)
	_show_result("✗ 错误举证！信任值 -1", Color(1, 0.5, 0.5))
	await get_tree().create_timer(1.4).timeout
	_result_label.visible = false
	_phase = Phase.TESTIMONY
	_set_face(FACE_NERVOUS)
	_refresh_statements()
	_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

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
	_set_face(FACE_SHOCKED)
	_show_result("⚖  GAME OVER  ⚖\n按 [R] 重开", Color(1, 0.4, 0.4))
	_set_hint("")
