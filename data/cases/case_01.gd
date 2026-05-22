# -*- coding: utf-8 -*-
# 第一话案件数据 — 证人证词 + 可用证据
class_name Case01
extends RefCounted

const WITNESS_NAME: String = "山田太郎"
const TESTIMONY_TITLE: String = "案发当晚的回忆"

# 证词条目：text 文本；breakable_with 用什么证据可击破；reveal 击破后台词
const STATEMENTS: Array = [
	{
		"text": "案发当晚9点到11点，我一直在房间里看综艺节目。",
		"breakable_with": "tv_outage_notice",
		"reveal": "唔啊啊啊！怎、怎么可能！"
	},
	{
		"text": "10点半左右我去厨房倒了一杯水。",
		"breakable_with": "",
		"reveal": ""
	},
	{
		"text": "我没听到任何动静，电视声音比较大。",
		"breakable_with": "",
		"reveal": ""
	}
]

# 案件开始时给玩家的证据
const INITIAL_EVIDENCE: Array = ["tv_outage_notice", "victim_watch", "footprint_photo"]
