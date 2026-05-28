# -*- coding: utf-8 -*-
# 第一话 — 改编自阿加莎·克里斯蒂《控方证人》的剧情骨架
#
# 玩家视角：辩护律师 Sir Wilfrid Robarts
# 所有对话为原创改编，仅保留戏剧反转节奏，不复用原作台词。
#
# 当前实现的 Stage：
#   0 - NARRATIVE: 律师事务所·初见
#   1 - TRIAL:     庭审第一日 · 管家证词
# (Stage 2 / 3 / 4 留待后续批次)
class_name Case01
extends RefCounted

const CASE_TITLE: String = "控方证人 · 改编验证版"

# Stage 类型常量（不用 enum，便于 const 字典直接写字符串）
const TYPE_NARRATIVE: String = "NARRATIVE"
const TYPE_TRIAL: String = "TRIAL"

# 每个 Stage 字段说明：
#   type:                 TYPE_NARRATIVE / TYPE_TRIAL
#   title:                标题（顶部 / 切换时显示）
#   scene_label:          场景文字（事务所 / 法庭等）
#   ---- NARRATIVE ----
#   dialog:               [{speaker, text}] 对话序列
#   unlock_on_complete:   完成此阶段时新增的证据 ID
#   ---- TRIAL ----
#   witness_name:         证人名
#   testimony_title:      证词主题
#   intro_dialog:         进入此阶段前的引导对话
#   statements:           [{speaker, text, breakable_with, reveal}]
#   stage_additions:      {statement_idx: [evidence_ids]} 选中证词时追加证据
#   outro_dialog:         所有可击破证词被击破后的过渡对话
#   unlock_on_complete:   完成此阶段时新增的证据 ID

const STAGES: Array = [
	# =========================================================
	# Stage 0 · 律师事务所·初见 (NARRATIVE)
	# =========================================================
	{
		"type": "NARRATIVE",
		"title": "第一幕 · 律师事务所",
		"scene_label": "律师事务所  ·  下午三点",
		"dialog": [
			{"speaker": "助理 Mayhew", "text": "韦菲爵士，门外有位先生求见。"},
			{"speaker": "Robarts", "text": "我以为我们已经讲清楚了——民事案件，离婚、遗产、合同。不接刑事。"},
			{"speaker": "助理 Mayhew", "text": "这位先生看上去比您刚出院那天还要憔悴。"},
			{"speaker": "Robarts", "text": "好吧。让他进来。我想看看一个比病人更糟糕的人是什么样子。"},
			{"speaker": "—", "text": "（一位年轻男子走进来。他衣着整洁但局促，手指无处安放。）"},
			{"speaker": "Leonard Vole", "text": "韦菲爵士，您愿意接见我，我万分感谢——"},
			{"speaker": "Robarts", "text": "先坐下。把你知道的事说一遍，连同你不愿告诉我的。"},
			{"speaker": "Leonard Vole", "text": "我叫 Leonard Vole，二十六岁。退伍三年，靠零工度日。"},
			{"speaker": "Leonard Vole", "text": "三周前的某个下午，我在牛津街替一位老太太搬了几个购物袋。她叫 Emily French。"},
			{"speaker": "Robarts", "text": "继续。她请你回家了？"},
			{"speaker": "Leonard Vole", "text": "她邀请我去喝茶。我推辞了两次。第三次她说她家里只有八只猫和一个聋管家，没人陪她说话。"},
			{"speaker": "Leonard Vole", "text": "之后我去过她家——大约九次或十次。我们下棋。她喜欢有人陪。"},
			{"speaker": "Robarts", "text": "她知道你已婚？"},
			{"speaker": "Leonard Vole", "text": "······这是个我一直没说清楚的话题。"},
			{"speaker": "Robarts", "text": "继续。出了什么事。"},
			{"speaker": "Leonard Vole", "text": "上周三的清晨，两位警察来到我公寓门口。他们说——Emily 在自己家中被打死了。"},
			{"speaker": "Leonard Vole", "text": "他们说案发时间是六月三日，晚上九点半到十点之间。"},
			{"speaker": "Robarts", "text": "那个时间你在哪？"},
			{"speaker": "Leonard Vole", "text": "我在家。和我妻子 Romaine 在一起。整晚都在。"},
			{"speaker": "Robarts", "text": "Romaine 愿意作证？"},
			{"speaker": "Leonard Vole", "text": "她愿意。但警察告诉我——她不能为我作辩方证人。这是真的吗？"},
			{"speaker": "Robarts", "text": "······是真的。根据当前的英国法律，妻子不能为丈夫作辩方证人——她只可能为控方作证。"},
			{"speaker": "Leonard Vole", "text": "（沉默良久。）"},
			{"speaker": "助理 Mayhew", "text": "（递来一份文件）韦菲爵士——这位的事情还有一处不太妙。"},
			{"speaker": "Robarts", "text": "（翻看文件，眉头一皱）Vole 先生。Emily French 在死前两周修改了遗嘱。"},
			{"speaker": "Robarts", "text": "她把绝大部分财产——大约八万英镑——留给了你。"},
			{"speaker": "Leonard Vole", "text": "······什么？"},
			{"speaker": "Robarts", "text": "你不知道这件事？"},
			{"speaker": "Leonard Vole", "text": "我以我母亲的名义发誓，我从来不知道。"},
			{"speaker": "Robarts", "text": "（注视他良久）"},
			{"speaker": "Robarts", "text": "Vole 先生。坐在那张椅子上哭过的人，我见过几百个——清白的、有罪的、装作清白的、装作有罪的。"},
			{"speaker": "Robarts", "text": "你属于哪一种？"},
			{"speaker": "Leonard Vole", "text": "······我没杀她。"},
			{"speaker": "Robarts", "text": "（停顿）Mayhew！"},
			{"speaker": "助理 Mayhew", "text": "韦菲爵士？"},
			{"speaker": "Robarts", "text": "把医生赶出去。这个案子我接。"},
			{"speaker": "—", "text": "—— 第一幕 完 ——"}
		],
		"unlock_on_complete": ["police_report", "will_amendment", "leonard_statement"]
	},

	# =========================================================
	# Stage 1 · 庭审第一日 · 管家证词 (TRIAL)
	# =========================================================
	{
		"type": "TRIAL",
		"title": "第二幕 · 庭审第一日",
		"scene_label": "中央刑事法庭  ·  开庭日",
		"witness_name": "Janet MacKenzie",
		"testimony_title": "案发当晚的回忆",
		"intro_dialog": [
			{"speaker": "助理 Mayhew", "text": "韦菲爵士，开庭了。陪审团十二人到齐。"},
			{"speaker": "Robarts", "text": "我们的胜算？"},
			{"speaker": "助理 Mayhew", "text": "说实话——很低。"},
			{"speaker": "Robarts", "text": "我喜欢低胜算。它逼我把每一句话都用到极致。"},
			{"speaker": "Wainwright 法官", "text": "本庭今日审理 Leonard Vole 被诉谋杀 Emily French 一案。"},
			{"speaker": "检察官 Myers", "text": "尊敬的法官阁下，控方将证明被告 Leonard Vole 出于贪图遗产之目的，于六月三日晚九点半至十点之间，在受害者家中将其杀害。"},
			{"speaker": "检察官 Myers", "text": "现传唤控方第一证人——Janet MacKenzie，受害者生前管家。"},
			{"speaker": "Janet MacKenzie", "text": "我叫 Janet MacKenzie，在 French 太太家做了二十一年管家。她待我像亲人。"},
			{"speaker": "Janet MacKenzie", "text": "直到那个年轻人闯进了她的生活。我从一开始就觉得他来者不善。"},
			{"speaker": "Robarts", "text": "（低声）她在说她相信的事，不是她知道的事。这种证人最难对付。"}
		],
		"statements": [
			{
				"speaker": "Janet MacKenzie",
				"text": "我每晚九点半都在客厅整理银器，那天 French 太太也在客厅。这是日常。",
				"breakable_with": "",
				"reveal": ""
			},
			{
				"speaker": "Janet MacKenzie",
				"text": "六月三日晚上九点四十分，我清清楚楚听见这个年轻人离开客厅的脚步声。",
				"breakable_with": "doctor_note",
				"reveal": "我······（声音颤抖）我虽然耳朵不那么好使，但是脚步声是能感觉到的！地板会动！"
			},
			{
				"speaker": "Janet MacKenzie",
				"text": "事发前一周，我亲眼撞见这个年轻人翻 French 太太的抽屉，鬼鬼祟祟地。",
				"breakable_with": "emily_letter",
				"reveal": "什么信？她从没跟我说过她请他帮忙······（沉默良久）也许······她不想让我知道。"
			},
			{
				"speaker": "Janet MacKenzie",
				"text": "他那天晚上离开时神色慌张，门都没关好就走了。这绝不是清白人的样子。",
				"breakable_with": "",
				"reveal": ""
			},
			{
				"speaker": "Janet MacKenzie",
				"text": "我和 French 太太情同母女，二十一年了。她若有任何心事都会告诉我——这是我最后能为她做的事。",
				"breakable_with": "will_amendment",
				"reveal": "······她改遗嘱的事，她从来没告诉我。我以为我配得上更多——我以为她也是这么想的。"
			}
		],
		"stage_additions": {
			1: ["doctor_note"],
			2: ["emily_letter"]
		},
		"outro_dialog": [
			{"speaker": "Robarts", "text": "Mackenzie 女士，我没有进一步的问题。请下席。"},
			{"speaker": "—", "text": "（Janet 离席，神情复杂。）"},
			{"speaker": "助理 Mayhew", "text": "（低声）她碎了。证词站不住。"},
			{"speaker": "Robarts", "text": "她不是坏人。她只是太爱 Emily 了——爱得分不清事实和怨恨。"},
			{"speaker": "Robarts", "text": "下一位证人是谁？"},
			{"speaker": "助理 Mayhew", "text": "······是 Vole 太太。Romaine Vole。"},
			{"speaker": "Robarts", "text": "Leonard 的妻子？她不是只能作控方证人吗？"},
			{"speaker": "助理 Mayhew", "text": "韦菲爵士——她**是**作为控方证人出庭。"},
			{"speaker": "Robarts", "text": "······你说什么？"},
			{"speaker": "—", "text": "—— 第二幕 完 (To be continued) ——"}
		],
		"unlock_on_complete": []
	}
]
