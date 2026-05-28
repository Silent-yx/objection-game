# -*- coding: utf-8 -*-
# 第一话《绿色圆圈案》案件数据
#
# 改编自 USTC 真实事件「绿色圆圈」— 少年班学生不识辣椒
# 详细剧情见 docs/story.md
class_name Case01
extends RefCounted

const WITNESS_NAME: String = "赵为 / 钱方达"
const TESTIMONY_TITLE: String = "宫保鸡丁案 · 被害人代述"

# 证词条目字段：
#   speaker         谁在说（"赵为转述" / "钱方达"）
#   text            证词文本
#   breakable_with  用什么证据 ID 可击破（空字符串 = 不可击破）
#   reveal          击破后的揭示台词
const STATEMENTS: Array = [
	{
		"speaker": "赵为转述",
		"text": "被害人事前一再强调他点的是『不辣的菜』。",
		"breakable_with": "lunch_receipt",
		"reveal": "……（赵为停顿）小票上确实写着『中辣』。但被告，这只能说明被害人不认识那个字……"
	},
	{
		"speaker": "钱方达",
		"text": "我亲眼看到这位同学（指易南星）从小研旁边经过时，手伸进了他的餐盘！",
		"breakable_with": "seat_photo",
		"reveal": "啊？……可能、可能是我看错了？我那时候在背元素周期表……"
	},
	{
		"speaker": "赵为转述",
		"text": "被害人坚持说菜里的『绿色圆圈』是人为投放的、不该出现在菜里。",
		"breakable_with": "cafeteria_menu",
		"reveal": "……『含干辣椒』。这是宫保鸡丁的标准配料。"
	},
	{
		"speaker": "钱方达",
		"text": "小研从来没吃过那种东西，肯定不是他自己点的！",
		"breakable_with": "redbook_post",
		"reveal": "等等，这是上周……小研同学之前就遇到过『绿色小怪兽』？"
	}
]

# 开局即在物品栏的证据（2 件）
const INITIAL_EVIDENCE: Array = ["cafeteria_menu", "seat_photo"]

# 庭审推进时自动追加的证据
# Key 为「证词索引（首次被选中时触发）」，Value 为「要追加的证据 ID 列表」
const STAGE_ADDITIONS: Dictionary = {
	0: ["lunch_receipt"],     # 选证词 1 时：周阿姨递交小票
	1: ["redbook_post"],      # 选证词 2 时：易南星掏出小红书截图
	2: ["chili_specimen"]     # 选证词 3 时：主持人收上干辣椒标本
}
