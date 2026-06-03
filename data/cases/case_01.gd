# -*- coding: utf-8 -*-
# 第一话 — 改编自阿加莎·克里斯蒂《控方证人》的剧情骨架
#
# 玩家视角：辩护律师 Sir Wilfrid Robarts
# 所有对话为原创改编，仅保留戏剧反转节奏，不复用原作台词。
#
# 当前实现的 Stage（五幕全实装）：
#   0 - NARRATIVE: 律师事务所·初见
#   1 - TRIAL:     庭审第一日 · 管家 Janet 证词
#   2 - TRIAL:     庭审第二日 · Christine 反水（NARRATIVE_TRIAL 机制失灵幕）
#   3 - TRIAL:     庭审第三日 · 神秘信件击破 Christine（伪胜利）
#   4 - NARRATIVE: 庭审后真相 + 弑夫终幕
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
#   set_truth_revealed:   true 则进入此阶段时揭示真相，触发证据细节翻转（仅终幕用）
#   ---- NARRATIVE ----
#   dialog:               [{speaker, text, inspect_evidence?}] 对话序列
#                         inspect_evidence: 该行自动摊开指定证据的（已翻转）细节
#   unlock_on_complete:   完成此阶段时新增的证据 ID
#   ---- TRIAL ----
#   trial_mode:           "STANDARD"(默认) 走击破推进 / "NARRATIVE_TRIAL" 走机制失灵幕
#                         （出示即反杀、不扣信任值，反杀累计到阈值后 Robarts 自动认输）
#   witness_name:         证人名
#   testimony_title:      证词主题
#   intro_dialog:         进入此阶段前的引导对话
#   statements:           [{speaker, text, breakable_with, reveal, backfire?, backfire_default?}]
#                         backfire: {evidence_id: 反杀台词}（NARRATIVE_TRIAL 用，per-证据定制）
#                         backfire_default: 出示任意未命中证据时的兜底反杀台词
#   stage_additions:      {statement_idx: [evidence_ids]} 选中证词时追加证据
#   outro_dialog:         所有可击破证词被击破后（或认输后）的过渡对话
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
	},

	# =========================================================
	# Stage 2 · 庭审第二日 · Christine 反水 (TRIAL · NARRATIVE_TRIAL)
	# 机制失灵幕：核心证词不可破，出示即反杀、不扣信任值，
	# 反杀累计到阈值后 Robarts 自动认输 → outro（神秘女人登场）
	# =========================================================
	{
		"type": "TRIAL",
		"trial_mode": "NARRATIVE_TRIAL",
		"title": "第三幕 · 庭审第二日",
		"scene_label": "中央刑事法庭  ·  庭审第二日",
		"witness_name": "Christine Vole",
		"testimony_title": "那一夜，他回来时",
		"intro_dialog": [
			{"speaker": "Robarts", "text": "（低声）控方传唤辩方的妻子……Myers 究竟想干什么。"},
			{"speaker": "检察官 Myers", "text": "控方传唤证人——Christine Vole。"},
			{"speaker": "—", "text": "（一个身着深色衣裙的女人走上证人席。她不看被告席，目光平静得像结了冰的湖面。）"},
			{"speaker": "Christine", "text": "我叫 Christine Vole。我是被告的妻子。（停顿）……在法律上，是。"},
			{"speaker": "Robarts", "text": "（低声）「在法律上」？这是什么说法……"},
			{"speaker": "Wainwright 法官", "text": "Vole 太太，本庭提醒您：您没有义务作出可能使您丈夫入罪的陈述。"},
			{"speaker": "Christine", "text": "我明白，法官阁下。但我今天来，是为了说出真相——无论它对谁不利。"},
			{"speaker": "Leonard Vole", "text": "（从被告席）Romaine……？你在说什么？Romaine！"},
			{"speaker": "Christine", "text": "（连眼皮都没抬）请不要再用那个名字叫我。"},
			{"speaker": "Robarts", "text": "（低声，心头一沉）……这不是一张来救丈夫的脸。Mayhew，我们的麻烦大了。"}
		],
		"statements": [
			{
				"speaker": "Christine",
				"text": "六月三日晚上，Leonard 并不像他说的那样整晚陪着我。九点刚过，他就独自出了门。",
				"breakable_with": "",
				"reveal": "",
				"backfire": {
					"leonard_statement": "Christine（不为所动）：「那是他要你们相信的版本，爵士。我为什么要替一个杀人犯，把谎言说得更圆？」"
				},
				"backfire_default": "Christine 静静看着你，等你把话说完。「您还有别的吗？」"
			},
			{
				"speaker": "Christine",
				"text": "他回来时，我看了钟，是十点十分。他衬衫的袖口上……沾着几点暗红色的痕迹。",
				"breakable_with": "",
				"reveal": "",
				"backfire_default": "Wainwright 法官：「Robarts 爵士，证人是在陈述她的亲眼所见。您手上可有反驳『她看见了什么』的证据？」——你没有。"
			},
			{
				"speaker": "Christine",
				"text": "他站在我面前，声音抖得不成样子，对我说了一句话——「我杀了她，Christine。我没忍住。」",
				"breakable_with": "",
				"reveal": "",
				"backfire_default": "Robarts（低声）：「这是一句没有第三个人听见的话。我证明不了它没被说过……也证明不了它被说过。」"
			},
			{
				"speaker": "Christine",
				"text": "我曾经爱过他。可我不能站在上帝面前，替一个杀人犯起誓说谎。",
				"breakable_with": "",
				"reveal": "",
				"backfire": {
					"will_amendment": "Christine（唇角微动）：「遗产？你以为我图他那八万英镑？爵士，我图的东西，你给不起。」"
				},
				"backfire_default": "Christine：「您可以质疑我的动机，爵士。可您动摇不了我说出的话。」"
			},
			{
				"speaker": "Christine",
				"text": "至于他口口声声的那个『不在场证明』——是他跪下来求我编的。我做不到。我的良心做不到。",
				"breakable_with": "",
				"reveal": "",
				"backfire": {
					"leonard_statement": "Christine：「一个肯为丈夫的谎言起誓的妻子，和一个肯说出真相的妻子——陪审团会信哪一个？……您心里清楚，爵士。」"
				},
				"backfire_default": "Christine 不再看你。「我说完了。」"
			}
		],
		"stage_additions": {
			1: ["christine_testimony"]
		},
		"outro_dialog": [
			{"speaker": "Wainwright 法官", "text": "Robarts 爵士，您还要继续询问证人吗？"},
			{"speaker": "Robarts", "text": "（罕见地沉默良久）……今天，没有了，法官阁下。"},
			{"speaker": "助理 Mayhew", "text": "（低声，震惊）韦菲爵士，您这辈子没说过『今天没有了』。"},
			{"speaker": "Robarts", "text": "因为我手里没有一样能撼动她的东西。她的每句话都像钉子，钉得严丝合缝。"},
			{"speaker": "Robarts", "text": "一个深爱丈夫的妻子撒谎救他——陪审团懂这个，会打折扣。可一个亲口指证丈夫的妻子……他们只会以为那是泣血的真话。"},
			{"speaker": "助理 Mayhew", "text": "那我们还剩什么？"},
			{"speaker": "Robarts", "text": "我们需要一样新东西。能证明她不是在泣血——而是在表演的东西。"},
			{"speaker": "—", "text": "（散庭。法庭外阴冷的走廊里，一个裹着旧围巾、操着浓重伦敦土腔的女人，闪身贴到 Robarts 身边。）"},
			{"speaker": "神秘女人", "text": "爵士……想不想要点东西，能让那位高贵的 Vole 太太，当众下不来台？"},
			{"speaker": "Robarts", "text": "……你是什么人？"},
			{"speaker": "神秘女人", "text": "我是谁不打紧。打紧的是我手上有信——她亲笔写的信。看过的人，没有不改主意的。（嗤笑）当然喽，不白给。"},
			{"speaker": "Robarts", "text": "（盯着她）……信在哪。"},
			{"speaker": "神秘女人", "text": "钱货两清，明早老地方。带上你想赢的那颗心，爵士。"},
			{"speaker": "—", "text": "—— 第三幕 完 ——"}
		],
		"unlock_on_complete": ["christine_testimony"]
	},

	# =========================================================
	# Stage 3 · 庭审第三日 · 神秘信件击破 Christine (TRIAL · 标准)
	# 伪胜利：christine_letters 逐条击破 → 无罪释放 → 玩家以为大获全胜
	# =========================================================
	{
		"type": "TRIAL",
		"title": "第四幕 · 庭审第三日",
		"scene_label": "中央刑事法庭  ·  庭审第三日",
		"witness_name": "Christine Vole",
		"testimony_title": "重新传唤 · 一个女人的可信度",
		"intro_dialog": [
			{"speaker": "助理 Mayhew", "text": "韦菲爵士，您真要用这些信？我们连那个卖信的女人是谁都不知道。"},
			{"speaker": "Robarts", "text": "来路我不喜欢。可我比对过——信上的字迹，和 Christine 在结婚登记簿上的签名，出自同一只手。"},
			{"speaker": "助理 Mayhew", "text": "万一是伪造的呢？"},
			{"speaker": "Robarts", "text": "（把信收进卷宗）Mayhew，溺水的人不会去问递来的那只手干不干净。今天，我要让陪审团看看，那位『泣血的妻子』到底在为谁泣血。"},
			{"speaker": "Wainwright 法官", "text": "Robarts 爵士，您申请重新传唤证人 Christine Vole？"},
			{"speaker": "Robarts", "text": "是的，法官阁下。我掌握了直接关乎本证人证言可信度的新证据。"},
			{"speaker": "—", "text": "（Christine 再次走上证人席。她依旧平静，可指尖在栏杆上轻轻收紧了一下。）"},
			{"speaker": "Christine", "text": "……你还想问什么，爵士？"},
			{"speaker": "Robarts", "text": "我想请您，再向陪审团确认几件事。慢慢来——我有的是耐心。"}
		],
		"statements": [
			{
				"speaker": "Christine",
				"text": "我已经说过了。我是怀着沉痛的心情，说出我丈夫犯下的罪行。",
				"breakable_with": "christine_letters",
				"reveal": "（Robarts 当庭朗读）「……等这一切结束，等他被送上绞架，我们就再没人挡得住了。」——Christine 脸色骤变：「那……那不是你该看到的东西！」"
			},
			{
				"speaker": "Christine",
				"text": "我和 Leonard 之间只有婚姻。我的生活里没有别的男人。",
				"breakable_with": "christine_letters",
				"reveal": "「我亲爱的 Max——」满纸都是写给另一个男人的情话。Christine（声音发紧）：「……一个女人写几封信，就该被钉在耻辱柱上？」"
			},
			{
				"speaker": "Christine",
				"text": "我站上这个证人席，是出于良心，我不图任何东西。",
				"breakable_with": "christine_letters",
				"reveal": "「只要他不在了，钱、自由、还有你——全都是我们的。」Robarts：「这就是您的『良心』，Vole 太太？」——Christine 第一次说不出话。"
			}
		],
		"stage_additions": {
			0: ["christine_letters"]
		},
		"outro_dialog": [
			{"speaker": "Christine", "text": "你……你赢不了的，爵士。你根本不知道你在做什么。"},
			{"speaker": "Robarts", "text": "陪审团的女士们、先生们。一个肯为情人盼着丈夫上绞架的女人，她说的每一个字，还值得你们相信吗？"},
			{"speaker": "检察官 Myers", "text": "（起身，又颓然坐下）……控方，没有再询问。"},
			{"speaker": "Wainwright 法官", "text": "陪审团是否已经达成裁决？"},
			{"speaker": "陪审团主席", "text": "是的，法官阁下。我们一致裁定——被告 Leonard Vole……无罪。"},
			{"speaker": "—", "text": "（旁听席哗然，继而爆发出议论与零星的喝彩。）"},
			{"speaker": "Leonard Vole", "text": "（冲到栏杆前，热泪盈眶）韦菲爵士！您救了我！我就知道——我就知道您一定能！"},
			{"speaker": "Robarts", "text": "（难得地笑了）我说过，我喜欢低胜算。它逼我把每一句话都用到极致。"},
			{"speaker": "助理 Mayhew", "text": "漂亮的一仗，爵士。是那女人的伪证，亲手毁了她自己。"},
			{"speaker": "Robarts", "text": "（点燃一支被医生明令禁止的雪茄，深吸一口）有时候啊，Mayhew，正义需要一点……不太干净的运气。"},
			{"speaker": "—", "text": "（人群渐渐散去，法庭空了下来。Robarts 独自收拾卷宗。一个身影，始终没有离开。）"},
			{"speaker": "Christine", "text": "恭喜你，爵士。你赢了。"},
			{"speaker": "Robarts", "text": "（抬头）Vole 太太？……您输掉了一切，却回来道贺？"},
			{"speaker": "Christine", "text": "我不是来道贺的。我是来……谢谢你的。（极淡地笑了一下）不——是来谢谢我自己的。"},
			{"speaker": "—", "text": "—— 第四幕 完 ——"}
		],
		"unlock_on_complete": []
	},

	# =========================================================
	# Stage 4 · 庭审后真相 + 弑夫终幕 (NARRATIVE)
	# 两层反转：信件是 Christine 伪造 + Leonard 真有罪 → 露真面目 → 弑夫 → Robarts 接案
	# set_truth_revealed：进场揭示真相，christine_letters 细节翻转
	# =========================================================
	{
		"type": "NARRATIVE",
		"title": "终幕 · 庭审之后",
		"scene_label": "中央刑事法庭  ·  人去庭空",
		"set_truth_revealed": true,
		"dialog": [
			{"speaker": "—", "text": "（旁听席空了，灯一盏盏熄灭。偌大的法庭只剩 Robarts 和那个没有离开的女人。）"},
			{"speaker": "Robarts", "text": "……我不明白，Vole 太太。您输掉了一切，却说要谢自己。"},
			{"speaker": "Christine", "text": "你不明白的事，还多着呢，爵士。比如——那个把信卖给你的女人。那个操着伦敦腔、贪几个脏钱的下作女人。"},
			{"speaker": "Robarts", "text": "她怎么了？"},
			{"speaker": "Christine", "text": "（声音骤然一变，切成浓重的伦敦土腔）「爵士……想不想要点东西，能让那位高贵的 Vole 太太，当众下不来台？」"},
			{"speaker": "Robarts", "text": "（骇然后退）……是你。那个卖信的女人，是你。"},
			{"speaker": "Christine", "text": "（恢复那把冷静的嗓音）一个在柏林的舞台上站了十年、会说七国话的女人，扮一个伦敦下女，不算太难，对吧。"},
			{"speaker": "Robarts", "text": "那些信……"},
			{"speaker": "Christine", "text": "我写的。每一个字，每一封。包括那个根本不存在的情人——「Max」。"},
			{"speaker": "Robarts", "text": "你伪造证据，去陷害你自己？！到底为了什么——"},
			{"speaker": "Christine", "text": "为了救他。从头到尾，只为了这一件事。"},
			{"speaker": "Christine", "text": "你是个聪明人，爵士，我头一天就看出来了。可聪明人有个通病——你们只肯信『自己亲手挖出来的真相』。"},
			{"speaker": "Christine", "text": "你想想，要是我哭着站上证人席，说『我丈夫是清白的，那一夜他一直在我身边』——陪审团会怎么想？"},
			{"speaker": "Robarts", "text": "……一个深爱丈夫的妻子，会为他撒谎。"},
			{"speaker": "Christine", "text": "对。我的爱，只会变成勒死他的绳子。所以我不能给他我的爱——我得给他，你的胜利。"},
			{"speaker": "Christine", "text": "我把自己做成一个可恨的、说谎的毒妇，送到你面前，让你去揭穿。你揭穿得越干净，他就越清白。你不是在为 Leonard 辩护，爵士——你是在照着我写好的本子，一句一句，念台词。"},
			{"speaker": "Robarts", "text": "（踉跄着扶住桌沿）那些信……我亲口读给陪审团听的那些信……"},
			{"speaker": "Christine", "text": "现在，再回头看看它们吧。", "inspect_evidence": "christine_letters"},
			{"speaker": "Christine", "text": "「等他被送上绞架，我们就自由了」——你当那是恶毒。那是我能编出来、最蹩脚的一个破绽，特意留给你去发现的。", "inspect_evidence": "christine_letters"},
			{"speaker": "Robarts", "text": "（喃喃）我越是得意……我就越是……"},
			{"speaker": "Christine", "text": "越是帮了我。是的，爵士。"},
			{"speaker": "Robarts", "text": "……那么六月三日那一夜呢。"},
			{"speaker": "Christine", "text": "他十点十分回的家。衣袖上沾着血。他站在我面前，对我说：「我杀了她，Christine。我没忍住。」"},
			{"speaker": "Robarts", "text": "那是你的证词。是假的。是你演的——"},
			{"speaker": "Christine", "text": "（极平静）那是我从头到尾，唯一的一句真话。我把真相，藏进了你最不肯相信的地方——藏在一个『被我亲手戳穿的谎言』里。"},
			{"speaker": "Robarts", "text": "……他真的杀了她。而我，亲手把一个杀人犯，送回了大街上。"},
			{"speaker": "Leonard Vole", "text": "（推门进来，一身轻松）Romaine！都结束啦！我们自由了！"},
			{"speaker": "Christine", "text": "（转身，眼里头一次有了光）是的，Leonard。我们自由了。我答应过你，我会把你从那里换下来——我做到了。"},
			{"speaker": "Leonard Vole", "text": "你太了不起了，真的。……不过呢，亲爱的，有件事我得趁早跟你说。"},
			{"speaker": "Christine", "text": "什么事？"},
			{"speaker": "Leonard Vole", "text": "那个姑娘，Diana……我跟她，（笑）你懂的。等这阵风头过了，我打算和她——"},
			{"speaker": "Christine", "text": "……你说什么？"},
			{"speaker": "Leonard Vole", "text": "别这么看着我。咱俩之间，早就只剩这桩案子了，不是吗？你救了我，我领情。可一个男人，总得往前看。"},
			{"speaker": "Christine", "text": "我为了你……我把我自己、我的名誉、我活着的全部体面，亲手钉死在那张证人席上。我让全英国都当我是荡妇、是骗子、是毒妇——"},
			{"speaker": "Leonard Vole", "text": "而且演得真好。我说真的。"},
			{"speaker": "Christine", "text": "——就为了把你，从那根绞索底下，换下来。"},
			{"speaker": "Leonard Vole", "text": "（耸肩）那我这不下来了嘛。皆大欢喜。"},
			{"speaker": "Robarts", "text": "（后退一步，声音发冷）……法律已经救不了你了，Vole。一事不再理。你为这桩案子被判过无罪，世上没有任何一个法庭，能再审你第二次。你，是安全的。"},
			{"speaker": "Leonard Vole", "text": "（大笑）听见没有，Romaine？我是安全的。谢谢你呀，亲爱的。也谢谢您，韦菲爵士。"},
			{"speaker": "Christine", "text": "（目光缓缓落到证物桌上那把刀）……安全的。"},
			{"speaker": "—", "text": "（她伸手，握住了那把作为呈堂证物的刀。）"},
			{"speaker": "Robarts", "text": "Christine——！"},
			{"speaker": "Leonard Vole", "text": "喂，你要干什——"},
			{"speaker": "—", "text": "（一道寒光。Leonard 的笑僵在脸上，他缓缓低头，看向自己的胸口。）"},
			{"speaker": "Leonard Vole", "text": "……Ro……maine……"},
			{"speaker": "—", "text": "（他倒了下去。这一次，没有人能再救他——也没有人，想救他。）"},
			{"speaker": "Christine", "text": "（刀当啷落地，她平静得可怕）……他想第二次，从我手里逃走。这一次，我不准。"},
			{"speaker": "助理 Mayhew", "text": "（冲进来）爵士！出什么事了——天哪……！我这就去喊人，当庭杀人，她跑不了的，她——"},
			{"speaker": "Robarts", "text": "（轻声）Mayhew。"},
			{"speaker": "助理 Mayhew", "text": "爵士？"},
			{"speaker": "Robarts", "text": "（弯腰，捡起那本被他翻烂了的卷宗，又看了 Christine 一眼）……这个案子，我接。"},
			{"speaker": "助理 Mayhew", "text": "您说什么？您要替她辩护？可她，她当着您的面就——"},
			{"speaker": "Robarts", "text": "她为一个杀人犯，演了整整一场戏，骗过了我，骗过了陪审团，骗过了全英国。（停顿，望向她）……现在，该轮到我，为她，演一场了。"},
			{"speaker": "—", "text": "——  全剧 终  ——"}
		],
		"unlock_on_complete": []
	}
]
