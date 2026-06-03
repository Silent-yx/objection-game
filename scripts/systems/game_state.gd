# -*- coding: utf-8 -*-
# 全局游戏状态：信任值、当前案件、当前证据
extends Node

signal trust_changed(new_value: int, max_value: int)
signal game_over()

const MAX_TRUST: int = 5

var trust: int = MAX_TRUST
var current_case_id: String = ""
var collected_evidence_ids: Array[String] = []
var truth_revealed: bool = false   # 终幕真相揭示后置真，触发部分证据的细节翻转

# 重置游戏状态
func reset() -> void:
	trust = MAX_TRUST
	collected_evidence_ids.clear()
	truth_revealed = false
	trust_changed.emit(trust, MAX_TRUST)

# 扣信任值
func penalize(amount: int = 1) -> void:
	trust = max(0, trust - amount)
	trust_changed.emit(trust, MAX_TRUST)
	if trust <= 0:
		game_over.emit()

# 添加证据
func add_evidence(evidence_id: String) -> void:
	if evidence_id not in collected_evidence_ids:
		collected_evidence_ids.append(evidence_id)
