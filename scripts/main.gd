# -*- coding: utf-8 -*-
# 主入口 — 多阶段案件运行器
#
# 案件结构（Case01.STAGES）：
#   NARRATIVE — 纯叙事对话页（按 SPACE 推进）
#   TRIAL     — 法庭举证页（intro_dialog → 证词举证 → outro_dialog → 下一阶段）
#
# 操作说明：
#   ↑/↓        选择证词
#   E          打开/关闭证据栏
#   ↑/↓ (栏内) 选择证据
#   D  (栏内)  调查证据 → 展开/收起「深度详情」
#   SPACE      DIALOG 中推进文字 / 证据栏内提交举证
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

# 缺图时的兜底背景（沿用第一话占位，待英伦背景补齐）
const BG_PLACEHOLDER = preload("res://assets/images/backgrounds/cafeteria_courtroom.png")

# 立绘明暗（当前说话人点亮、对方调暗）
const PORTRAIT_LIT := Color(1, 1, 1, 1)
const PORTRAIT_DIM := Color(1, 1, 1, 0.4)

# 角色注册表：说话人显示名 → {角色目录 id, 默认表情}
# 详见 docs/art-assets.md。Robarts 走右侧主角节点，旁白「—」与未注册者不切左侧立绘。
const CHARACTERS := {
	"Christine": {"id": "christine", "emotion": "normal"},
	"Christine Vole": {"id": "christine", "emotion": "normal"},
	"Leonard Vole": {"id": "leonard", "emotion": "nervous"},
	"Janet MacKenzie": {"id": "janet", "emotion": "normal"},
	"助理 Mayhew": {"id": "mayhew", "emotion": "normal"},
	"Wainwright 法官": {"id": "judge", "emotion": "normal"},
	"检察官 Myers": {"id": "myers", "emotion": "normal"},
	"神秘女人": {"id": "mystery_woman", "emotion": "normal"},
}

enum Phase { DIALOG, STATEMENTS, EVIDENCE_PICK, OBJECTION_PLAY, GAME_OVER, CLEAR }

# 对话结束后要执行的下一步
const AFTER_ADVANCE_STAGE: String = "advance_stage"
const AFTER_ENTER_STATEMENTS: String = "enter_statements"
const AFTER_OUTRO_ADVANCE: String = "outro_advance"

# ------- 运行时节点 -------
var _ui_layer: CanvasLayer
var _bg: TextureRect
var _protagonist: TextureRect           # 右侧主角 Robarts
var _witness: TextureRect               # 左侧当前说话证人/角色
# 顶部信息
var _scene_label: Label
var _stage_title: Label
var _trust_bar: HBoxContainer
# 对话页 UI
var _dialog_panel: Panel
var _dialog_speaker: Label
var _dialog_text: Label
var _dialog_continue: Label
# 庭审 UI
var _witness_label: Label
var _statement_container: VBoxContainer
var _statement_labels: Array[Label] = []
var _hint_label: Label
# 证据栏
var _evidence_panel: Panel
var _evidence_container: VBoxContainer
var _evidence_labels: Array[Label] = []
var _evidence_desc: Label
# 深度详情 + Toast
var _evidence_detail_panel: Panel
var _evidence_detail_label: Label
var _toast_label: Label
# 演出
var _flash: ColorRect
var _objection_sprite: TextureRect
var _result_label: Label

# ------- 状态 -------
var _phase: int = Phase.DIALOG
var _current_stage_idx: int = 0
var _current_stage: Dictionary = {}
# DIALOG 阶段
var _dialog_queue: Array = []
var _dialog_idx: int = 0
var _after_dialog_action: String = AFTER_ADVANCE_STAGE
# TRIAL 阶段
var _statement_idx: int = 0
var _evidence_idx: int = 0
var _statements: Array = []
var _evidence_ids: Array = []
var _correct_pair: Dictionary = {}        # statement_idx -> evidence_id
var _broken_statements: Array = []        # 已击破的证词索引
var _stages_triggered_additions: Array = []
var _detail_open: bool = false
var _trial_witness_speaker: String = ""   # 当前庭审证人（用于击破时切表情）
var _portrait_cache: Dictionary = {}       # 色块占位纹理缓存
# NARRATIVE_TRIAL（机制失灵幕）反杀暂存
const CONCEDE_THRESHOLD: int = 3          # 反杀达此次数后 Robarts 自动认输进 outro
var _pending_backfire_text: String = ""   # 本次出示要显示的定制反杀文案（空=非反杀）
var _pending_no_penalty: bool = false     # 本次出示是否豁免信任值扣减
var _backfire_count: int = 0              # 本幕累计反杀次数

# 节点准备
func _ready() -> void:
	randomize()
	GameState.reset()
	_build_ui()
	GameState.trust_changed.connect(_on_trust_changed)
	GameState.game_over.connect(_on_game_over)
	_start_stage(0)

# 构建所有 UI 节点（初始可见性按后续切换决定）
func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	add_child(_ui_layer)

	# 背景图
	_bg = TextureRect.new()
	_bg.texture = BG_CAFETERIA
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_bg)

	# 半透明遮罩
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.45)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(overlay)

	# 主角立绘（右下角）
	_protagonist = TextureRect.new()
	_protagonist.texture = FACE_NORMAL
	_protagonist.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_protagonist.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_protagonist.position = Vector2(880, 140)
	_protagonist.size = Vector2(380, 540)
	_protagonist.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_protagonist)

	# 证人立绘（左下角，对峙位）
	_witness = TextureRect.new()
	_witness.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_witness.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_witness.position = Vector2(20, 140)
	_witness.size = Vector2(380, 540)
	_witness.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_witness.visible = false
	_ui_layer.add_child(_witness)

	# 场景标签（左上）
	_scene_label = Label.new()
	_scene_label.position = Vector2(60, 16)
	_scene_label.add_theme_font_size_override("font_size", 16)
	_scene_label.modulate = Color(0.7, 0.85, 1, 0.85)
	_ui_layer.add_child(_scene_label)

	# 阶段标题
	_stage_title = Label.new()
	_stage_title.position = Vector2(60, 40)
	_stage_title.add_theme_font_size_override("font_size", 28)
	_stage_title.modulate = Color(1, 1, 1)
	_ui_layer.add_child(_stage_title)

	# 信任值条（顶部偏右）
	_trust_bar = HBoxContainer.new()
	_trust_bar.position = Vector2(1280 - 240, 24)
	_trust_bar.add_theme_constant_override("separation", 8)
	_ui_layer.add_child(_trust_bar)
	for i in GameState.MAX_TRUST:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(28, 28)
		pip.color = Color(0.93, 0.27, 0.38)
		_trust_bar.add_child(pip)

	# ===== 对话页 UI =====
	_dialog_panel = Panel.new()
	_dialog_panel.position = Vector2(60, 540)
	_dialog_panel.size = Vector2(1160, 160)
	_dialog_panel.visible = false
	_ui_layer.add_child(_dialog_panel)

	_dialog_speaker = Label.new()
	_dialog_speaker.position = Vector2(24, 12)
	_dialog_speaker.add_theme_font_size_override("font_size", 22)
	_dialog_speaker.modulate = Color(1, 0.85, 0.4)
	_dialog_panel.add_child(_dialog_speaker)

	_dialog_text = Label.new()
	_dialog_text.position = Vector2(24, 48)
	_dialog_text.size = Vector2(1110, 100)
	_dialog_text.add_theme_font_size_override("font_size", 22)
	_dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialog_panel.add_child(_dialog_text)

	_dialog_continue = Label.new()
	_dialog_continue.position = Vector2(1020, 122)
	_dialog_continue.text = "▶ [SPACE] 继续"
	_dialog_continue.add_theme_font_size_override("font_size", 14)
	_dialog_continue.modulate = Color(0.7, 0.85, 1, 0.6)
	_dialog_panel.add_child(_dialog_continue)

	# ===== 庭审 UI =====
	_witness_label = Label.new()
	_witness_label.position = Vector2(60, 90)
	_witness_label.add_theme_font_size_override("font_size", 20)
	_witness_label.modulate = Color(1, 0.85, 0.4)
	_witness_label.visible = false
	_ui_layer.add_child(_witness_label)

	_statement_container = VBoxContainer.new()
	_statement_container.position = Vector2(60, 150)
	_statement_container.custom_minimum_size = Vector2(800, 0)
	_statement_container.add_theme_constant_override("separation", 14)
	_statement_container.visible = false
	_ui_layer.add_child(_statement_container)

	# 提示
	_hint_label = Label.new()
	_hint_label.position = Vector2(60, 660)
	_hint_label.add_theme_font_size_override("font_size", 16)
	_hint_label.modulate = Color(0.85, 0.9, 1, 0.85)
	_ui_layer.add_child(_hint_label)

	# 证据栏
	_evidence_panel = Panel.new()
	_evidence_panel.position = Vector2(200, 180)
	_evidence_panel.size = Vector2(880, 400)
	_evidence_panel.visible = false
	_ui_layer.add_child(_evidence_panel)

	var ev_title := Label.new()
	ev_title.text = "🗂  证据栏  —  [D] 调查证物    [SPACE] 举证    [E] 关闭"
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

	# 深度详情
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
	_evidence_detail_panel.add_child(_evidence_detail_label)

	# Toast
	_toast_label = Label.new()
	_toast_label.position = Vector2(0, 100)
	_toast_label.size = Vector2(1280, 40)
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.add_theme_font_size_override("font_size", 22)
	_toast_label.modulate = Color(1, 0.9, 0.4, 0)
	_ui_layer.add_child(_toast_label)

	# 红光层
	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1, 0.1, 0.1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_flash)

	# 異議あり！大字图
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

	# 结果浮层
	_result_label = Label.new()
	_result_label.position = Vector2(0, 320)
	_result_label.size = Vector2(1280, 100)
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 32)
	_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_label.visible = false
	_ui_layer.add_child(_result_label)

# =========================================================
# Stage 推进
# =========================================================

# 启动指定阶段
func _start_stage(idx: int) -> void:
	if idx >= Case01.STAGES.size():
		_on_game_complete()
		return
	_current_stage_idx = idx
	_current_stage = Case01.STAGES[idx]
	# 切幕清场：左侧证人立绘归零，避免残留上一幕角色色块
	_witness.visible = false
	_witness.texture = null
	# 终幕进场：揭示真相，触发证据细节翻转
	if _current_stage.get("set_truth_revealed", false):
		GameState.truth_revealed = true
	_scene_label.text = str(_current_stage.get("scene_label", ""))
	_stage_title.text = str(_current_stage.get("title", ""))
	_bg.texture = _resolve_bg(str(_current_stage.get("bg", "")))
	var st_type: String = str(_current_stage.get("type", ""))
	if st_type == Case01.TYPE_NARRATIVE:
		_enter_dialog_mode(_current_stage.get("dialog", []), AFTER_ADVANCE_STAGE)
	elif st_type == Case01.TYPE_TRIAL:
		# 先播 intro_dialog
		_enter_dialog_mode(_current_stage.get("intro_dialog", []), AFTER_ENTER_STATEMENTS)
	else:
		push_error("Unknown stage type: %s" % st_type)

# 进入对话模式
func _enter_dialog_mode(dialog_array: Array, after_action: String) -> void:
	_phase = Phase.DIALOG
	_dialog_queue = dialog_array
	_dialog_idx = 0
	_after_dialog_action = after_action
	_hide_trial_ui()
	_dialog_panel.visible = true
	_set_face(FACE_NORMAL)
	_protagonist.modulate = PORTRAIT_LIT
	_witness.modulate = PORTRAIT_DIM
	_set_hint("[SPACE] 推进对话    [R] 重开")
	_show_dialog_at(_dialog_idx)

# 显示对话队列的第 idx 条
func _show_dialog_at(idx: int) -> void:
	if idx >= _dialog_queue.size():
		_on_dialog_finished()
		return
	var line: Dictionary = _dialog_queue[idx]
	_dialog_speaker.text = str(line.get("speaker", ""))
	_dialog_text.text = str(line.get("text", ""))
	_update_speaker_portrait(str(line.get("speaker", "")), str(line.get("emotion", "")))
	# 定向「证据再读」：终幕在特定台词自动摊开某证据的（已翻转）细节
	var reread: String = str(line.get("inspect_evidence", ""))
	if reread != "":
		_show_evidence_reread(reread)
	elif _detail_open:
		_evidence_detail_panel.visible = false
		_detail_open = false

# 对话队列播完
func _on_dialog_finished() -> void:
	match _after_dialog_action:
		AFTER_ADVANCE_STAGE:
			# 解锁此阶段的证据，再切下一 stage
			_unlock_stage_evidence()
			_start_stage(_current_stage_idx + 1)
		AFTER_ENTER_STATEMENTS:
			_enter_statements_phase()
		AFTER_OUTRO_ADVANCE:
			_unlock_stage_evidence()
			_start_stage(_current_stage_idx + 1)

# 解锁当前 stage 的 unlock_on_complete 证据（叙事段后批量加入，无 Toast）
func _unlock_stage_evidence() -> void:
	var to_unlock = _current_stage.get("unlock_on_complete", [])
	for eid in to_unlock:
		if eid not in _evidence_ids:
			_evidence_ids.append(eid)
			GameState.add_evidence(eid)

# 进入证词举证阶段
func _enter_statements_phase() -> void:
	_phase = Phase.STATEMENTS
	_statements = _current_stage.get("statements", [])
	_correct_pair = {}
	_broken_statements = []
	_stages_triggered_additions = []
	_backfire_count = 0
	_pending_backfire_text = ""
	_pending_no_penalty = false
	for i in _statements.size():
		var s: Dictionary = _statements[i]
		if s.get("breakable_with", "") != "":
			_correct_pair[i] = s["breakable_with"]
	_dialog_panel.visible = false
	_show_trial_ui()
	_witness_label.text = "证人： %s   《%s》" % [
		str(_current_stage.get("witness_name", "")),
		str(_current_stage.get("testimony_title", ""))
	]
	_trial_witness_speaker = str(_current_stage.get("witness_name", ""))
	_update_speaker_portrait(_trial_witness_speaker, "")
	_statement_idx = 0
	_rebuild_statement_labels()
	_refresh_statements()
	_refresh_evidence_list()
	_check_stage_additions(_statement_idx)
	_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

# 隐藏庭审相关 UI
func _hide_trial_ui() -> void:
	_witness_label.visible = false
	_statement_container.visible = false
	_evidence_panel.visible = false
	_evidence_detail_panel.visible = false
	_detail_open = false

# 显示庭审相关 UI
func _show_trial_ui() -> void:
	_witness_label.visible = true
	_statement_container.visible = true

# 根据 _statements 重建证词标签
func _rebuild_statement_labels() -> void:
	for child in _statement_container.get_children():
		child.queue_free()
	_statement_labels.clear()
	for s in _statements:
		var lbl := Label.new()
		lbl.add_theme_font_size_override("font_size", 19)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size = Vector2(800, 0)
		_statement_container.add_child(lbl)
		_statement_labels.append(lbl)

# 设置主角表情立绘
func _set_face(face: Texture2D) -> void:
	_protagonist.texture = face

# 按当前说话人切换左侧证人立绘 + 左右明暗对峙
func _update_speaker_portrait(speaker: String, emotion: String) -> void:
	if speaker == "Robarts":
		_protagonist.modulate = PORTRAIT_LIT
		_witness.modulate = PORTRAIT_DIM
		return
	if not CHARACTERS.has(speaker):
		# 旁白「—」/ 陪审团主席等未注册者：维持现状，不强切立绘
		return
	var info: Dictionary = CHARACTERS[speaker]
	var emo: String = emotion if emotion != "" else str(info["emotion"])
	_witness.texture = _portrait_texture(str(info["id"]), emo)
	_witness.visible = true
	_witness.modulate = PORTRAIT_LIT
	_protagonist.modulate = PORTRAIT_DIM

# 取角色某表情立绘：优先真图，其次该角色 normal，最后运行时色块占位
func _portrait_texture(char_id: String, emotion: String) -> Texture2D:
	var path: String = "res://assets/images/characters/%s/%s.png" % [char_id, emotion]
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
		push_warning("立绘存在但加载失败（可能未导入）: " + path)
	var path_normal: String = "res://assets/images/characters/%s/normal.png" % char_id
	if ResourceLoader.exists(path_normal):
		var res_n = load(path_normal)
		if res_n is Texture2D:
			return res_n
		push_warning("立绘存在但加载失败（可能未导入）: " + path_normal)
	return _placeholder_portrait(char_id, emotion)

# 运行时生成色块占位（按角色 id 取色相，受击表情转暗红），无需外部文件
func _placeholder_portrait(char_id: String, emotion: String) -> Texture2D:
	var key: String = char_id + ":" + emotion
	if _portrait_cache.has(key):
		return _portrait_cache[key]
	var col: Color
	if char_id == "mystery_woman":
		col = Color.from_hsv(0.62, 0.18, 0.12, 0.92)   # 神秘女人：近黑冷色剪影，不暴露身份
	elif emotion == "shaken" or emotion == "broken":
		col = Color.from_hsv(0.02, 0.6, 0.5, 0.9)   # 受击：暗红
	else:
		var hue: float = float(abs(char_id.hash()) % 360) / 360.0
		col = Color.from_hsv(hue, 0.45, 0.55, 0.85)
	var img: Image = Image.create(380, 540, false, Image.FORMAT_RGBA8)
	img.fill(col)
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	_portrait_cache[key] = tex
	return tex

# 取场景背景：优先真图，缺则兜底占位
func _resolve_bg(bg_key: String) -> Texture2D:
	if bg_key == "":
		return BG_PLACEHOLDER
	var path: String = "res://assets/images/backgrounds/%s.png" % bg_key
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
		push_warning("背景存在但加载失败（可能未导入）: " + path)
	return BG_PLACEHOLDER

# 组装证词文本（含说话人前缀 + 已击破标记）
func _format_statement(idx: int) -> String:
	var s: Dictionary = _statements[idx]
	var prefix := "▶ " if (idx == _statement_idx and _phase == Phase.STATEMENTS) else "  "
	var broken := " ✓" if idx in _broken_statements else ""
	var speaker = str(s.get("speaker", ""))
	if speaker == "":
		return "%s%s%s" % [prefix, str(s["text"]), broken]
	return "%s[%s] %s%s" % [prefix, speaker, str(s["text"]), broken]

# 刷新证词高亮
func _refresh_statements() -> void:
	for i in _statement_labels.size():
		var lbl := _statement_labels[i]
		lbl.text = _format_statement(i)
		if i in _broken_statements:
			lbl.modulate = Color(0.55, 0.85, 0.6)
		elif i == _statement_idx and _phase == Phase.STATEMENTS:
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

func _format_evidence_line(idx: int, display_name: String, has_detail: bool) -> String:
	var prefix := "▶ " if idx == _evidence_idx else "  "
	var detail_mark := "  🔍" if has_detail else ""
	return "%s%s%s" % [prefix, display_name, detail_mark]

func _refresh_evidence_highlight() -> void:
	for i in _evidence_labels.size():
		var ev = EvidenceDB.get_evidence(_evidence_ids[i])
		_evidence_labels[i].text = _format_evidence_line(i, ev.display_name, ev.has_detail())
		_evidence_labels[i].modulate = Color(1, 0.85, 0.3) if i == _evidence_idx else Color(0.95, 0.95, 0.95)
	if _evidence_ids.size() > 0:
		var sel = EvidenceDB.get_evidence(_evidence_ids[_evidence_idx])
		_evidence_desc.text = "  " + sel.description
		if _detail_open:
			_close_detail()

func _set_hint(text: String) -> void:
	_hint_label.text = text

# =========================================================
# 输入
# =========================================================
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: int = event.keycode

	if key == KEY_R:
		get_tree().reload_current_scene()
		return

	match _phase:
		Phase.DIALOG:
			if key == KEY_SPACE or key == KEY_ENTER:
				_dialog_idx += 1
				_show_dialog_at(_dialog_idx)
		Phase.STATEMENTS:
			_handle_testimony_input(key)
		Phase.EVIDENCE_PICK:
			_handle_evidence_input(key)
		_:
			pass

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

func _handle_evidence_input(key: int) -> void:
	if key == KEY_D:
		_toggle_evidence_detail()
		return
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

func _toggle_evidence_detail() -> void:
	if _detail_open:
		_close_detail()
	else:
		_open_detail()

func _open_detail() -> void:
	if _evidence_ids.size() == 0:
		return
	var ev = EvidenceDB.get_evidence(_evidence_ids[_evidence_idx])
	if ev == null:
		return
	# 调查面板用全尺寸（此时无对话框，可铺满）
	_evidence_detail_panel.position = Vector2(120, 100)
	_evidence_detail_panel.size = Vector2(1040, 520)
	if ev.has_detail():
		_evidence_detail_label.text = "「%s」\n\n%s" % [ev.display_name, _resolve_detail(ev)]
		_evidence_detail_label.modulate = Color(1, 1, 1)
	else:
		_evidence_detail_label.text = "「%s」\n\n暂无更多细节可调查。" % ev.display_name
		_evidence_detail_label.modulate = Color(0.7, 0.7, 0.75)
	_evidence_detail_panel.visible = true
	_detail_open = true
	_set_hint("[D] 关闭调查面板")

# 取证据当前应显示的细节（真相揭示后翻转为 detail_after）
func _resolve_detail(ev) -> String:
	if GameState.truth_revealed and ev.detail_after != "":
		return ev.detail_after
	return ev.detail

# 定向「证据再读」：终幕台词驱动，自动摊开指定证据的（已翻转）细节
func _show_evidence_reread(eid: String) -> void:
	var ev = EvidenceDB.get_evidence(eid)
	if ev == null:
		return
	# 紧凑几何：停在上半屏，避开底部对话框，让台词与翻转细节同屏可见
	_evidence_detail_panel.position = Vector2(120, 50)
	_evidence_detail_panel.size = Vector2(1040, 460)
	_evidence_detail_label.text = "「%s」\n\n%s" % [ev.display_name, _resolve_detail(ev)]
	_evidence_detail_label.modulate = Color(1, 1, 1)
	_evidence_detail_panel.visible = true
	_detail_open = true

func _close_detail() -> void:
	_evidence_detail_panel.visible = false
	_detail_open = false
	_set_hint("[↑↓] 选证据    [D] 调查    [SPACE] 举证！   [E] 关闭")

func _open_evidence_panel() -> void:
	_phase = Phase.EVIDENCE_PICK
	_evidence_idx = 0
	_evidence_panel.visible = true
	_set_face(FACE_THINKING)
	_refresh_statements()
	_refresh_evidence_highlight()
	_set_hint("[↑↓] 选证据    [D] 调查    [SPACE] 举证！   [E] 关闭")

func _close_evidence_panel() -> void:
	_phase = Phase.STATEMENTS
	_evidence_panel.visible = false
	_close_detail()
	_set_face(FACE_NORMAL)
	_refresh_statements()
	_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

# =========================================================
# 阶段追加证据
# =========================================================
func _check_stage_additions(idx: int) -> void:
	if idx in _stages_triggered_additions:
		return
	var sa = _current_stage.get("stage_additions", {})
	var to_add = sa.get(idx, [])
	if to_add.is_empty():
		return
	_stages_triggered_additions.append(idx)
	for eid in to_add:
		_add_evidence_runtime(eid)

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

func _show_toast(text: String) -> void:
	_toast_label.text = text
	var tw := create_tween()
	tw.tween_property(_toast_label, "modulate:a", 1.0, 0.25)
	tw.tween_interval(2.0)
	tw.tween_property(_toast_label, "modulate:a", 0.0, 0.4)

# =========================================================
# 举证 + 演出
# =========================================================
func _submit_evidence() -> void:
	if _phase != Phase.EVIDENCE_PICK:
		return
	_phase = Phase.OBJECTION_PLAY
	_evidence_panel.visible = false
	_close_detail()
	_set_face(FACE_POINTING)
	var chosen_evi_id: String = _evidence_ids[_evidence_idx]
	# NARRATIVE_TRIAL（机制失灵幕）：出示即反杀——算好定制反杀文案，不扣信任值
	if str(_current_stage.get("trial_mode", "STANDARD")) == "NARRATIVE_TRIAL":
		var s: Dictionary = _statements[_statement_idx]
		var bf: Dictionary = s.get("backfire", {})
		_pending_backfire_text = str(bf.get(chosen_evi_id, s.get("backfire_default", "")))
		_pending_no_penalty = true
		_play_objection(false)
		return
	# STANDARD：正常击破判定
	_pending_backfire_text = ""
	_pending_no_penalty = false
	var expected: String = _correct_pair.get(_statement_idx, "")
	if expected != "" and chosen_evi_id == expected:
		_play_objection(true)
	else:
		_play_objection(false)

func _play_objection(success: bool) -> void:
	var shake_tw := create_tween()
	for i in 8:
		var dx := randf_range(-18.0, 18.0)
		var dy := randf_range(-12.0, 12.0)
		shake_tw.tween_property(_ui_layer, "offset", Vector2(dx, dy), 0.04)
	shake_tw.tween_property(_ui_layer, "offset", Vector2.ZERO, 0.06)

	var flash_tw := create_tween()
	flash_tw.tween_property(_flash, "color:a", 0.55, 0.06)
	flash_tw.tween_property(_flash, "color:a", 0.0, 0.45)

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

func _on_objection_success() -> void:
	var idx := _statement_idx
	var reveal: String = str(_statements[idx].get("reveal", ""))
	if idx not in _broken_statements:
		_broken_statements.append(idx)
	_show_result("✓ 击破矛盾！\n%s" % reveal, Color(0.4, 1, 0.55))
	_set_face(FACE_POINTING)
	# 证人被击破：切受击表情，但 Robarts 举证高亮、证人退暗位
	_update_speaker_portrait(_trial_witness_speaker, str(_current_stage.get("break_emotion", "shaken")))
	_protagonist.modulate = PORTRAIT_LIT
	_witness.modulate = PORTRAIT_DIM
	# 判断是否所有可击破证词已全部击破
	if _all_breakable_broken():
		await get_tree().create_timer(2.5).timeout
		_result_label.visible = false
		_enter_outro_dialog()
	else:
		await get_tree().create_timer(2.0).timeout
		_result_label.visible = false
		_phase = Phase.STATEMENTS
		_set_face(FACE_NORMAL)
		_refresh_statements()
		_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

func _all_breakable_broken() -> bool:
	for idx in _correct_pair.keys():
		if idx not in _broken_statements:
			return false
	return true

func _enter_outro_dialog() -> void:
	var outro = _current_stage.get("outro_dialog", [])
	if outro.is_empty():
		_unlock_stage_evidence()
		_start_stage(_current_stage_idx + 1)
	else:
		_enter_dialog_mode(outro, AFTER_OUTRO_ADVANCE)

func _on_objection_fail() -> void:
	# NARRATIVE_TRIAL 反杀：不扣信任值，显示定制反杀文案（橙色），累计到阈值自动认输
	if _pending_no_penalty:
		_backfire_count += 1
		var bf_text: String = _pending_backfire_text if _pending_backfire_text != "" else "（你的证据撼动不了她分毫。）"
		_show_result(bf_text, Color(1, 0.85, 0.4))
		_set_face(FACE_NERVOUS)
		_pending_backfire_text = ""
		_pending_no_penalty = false
		await get_tree().create_timer(2.2).timeout
		_result_label.visible = false
		if _backfire_count >= CONCEDE_THRESHOLD:
			_concede_trial()
		else:
			_phase = Phase.STATEMENTS
			_set_face(FACE_NORMAL)
			_refresh_statements()
			_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")
		return
	# STANDARD 失败：扣信任值
	GameState.penalize(1)
	_set_face(FACE_SHOCKED)
	_show_result("✗ 错误举证！信任值 -1", Color(1, 0.5, 0.5))
	await get_tree().create_timer(1.5).timeout
	_result_label.visible = false
	_phase = Phase.STATEMENTS
	_set_face(FACE_NERVOUS)
	_refresh_statements()
	_set_hint("[↑↓] 选证词    [E] 翻证据栏    [R] 重开")

# NARRATIVE_TRIAL：无法击破，反杀累计到阈值后 Robarts 认输 → 进 outro（神秘女人登场）
func _concede_trial() -> void:
	_enter_outro_dialog()

func _show_result(text: String, color: Color) -> void:
	_result_label.text = text
	_result_label.modulate = color
	_result_label.visible = true

func _on_trust_changed(new_value: int, max_value: int) -> void:
	for i in _trust_bar.get_child_count():
		var pip := _trust_bar.get_child(i) as ColorRect
		pip.color = Color(0.93, 0.27, 0.38) if i < new_value else Color(0.3, 0.3, 0.35)

func _on_game_over() -> void:
	_phase = Phase.GAME_OVER
	_set_face(FACE_SHOCKED)
	_show_result("⚖  GAME OVER  ⚖\n按 [R] 重开", Color(1, 0.4, 0.4))
	_set_hint("")

# 全案结束（所有 stage 跑完）
func _on_game_complete() -> void:
	_phase = Phase.CLEAR
	_hide_trial_ui()
	_dialog_panel.visible = false
	_show_result("——  控方证人 · 全剧终  ——\n你赢下了官司，却输给了真相。\n按 [R] 重新开始", Color(0.7, 0.9, 1))
	_set_hint("")
