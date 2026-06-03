# 美术素材清单 — 《控方证人》英伦版

> 本文档是**美术素材的单一信息源**。你照此备图、引擎照此接入，命名/尺寸对齐即可零返工。
> 配套：[story.md](story.md)（剧情）、[script-stage2-4.md](script-stage2-4.md)（台词）。
> 范围：**完整逆转裁判式**——主角立绘 + 分场景背景 + 证人立绘（含表情切换）。

---

## 一、通用规格

| 项 | 规格 |
|---|---|
| 视口 | 1280 × 720 |
| 立绘格式 | **透明 PNG**，建议 760 × 1080（显示区约 380×540，留 2× 供清晰）；半身或全身，**人物水平居中、底部对齐** |
| 背景格式 | 不透明 PNG/JPG，1280 × 720（或 1920×1080 更清晰，引擎按 cover 裁切） |
| 特效格式 | 透明 PNG |
| 风格基调 | 1950s 英伦、冷峻严肃；避免日漫高饱和。参考油画/电影剧照质感 |
| 目录 | `assets/images/characters/<角色id>/<表情>.png`、`assets/images/backgrounds/<场景id>.png`、`assets/images/effects/<名>.png` |

> 优先级：**【必须】** = 不做会缺图露馅；**【高价值】** = 强烈建议，缺则用替代；**【可选】** = 锦上添花。

---

## 二、角色立绘清单（共 9 个角色）

> 出场频次（开口行数）：Robarts 58 · Christine 36 · Leonard 25 · Mayhew 17 · Janet 7 · 法官 5 · Myers 4 · 神秘女人 3 · 陪审团主席 1。

### 1. Robarts（主角 · 玩家）— `characters/robarts/`
辩护律师，心脏病初愈，冷峻毒舌。**右侧常驻立绘**，5 个表情对应引擎已有的情绪切换逻辑：

| 文件 | 表情 | 触发场景 | 优先级 |
|---|---|---|---|
| `normal.png` | 平静审视 | 默认 | 【必须】 |
| `thinking.png` | 沉思 | 打开证据栏 | 【必须】 |
| `pointing.png` | 举证质问（前倾/手指前指） | 提交举证、击破成功 | 【必须】 |
| `shocked.png` | 震惊 | S2 Christine 反水、S4 真相 | 【必须】 |
| `nervous.png` | 受挫凝重 | 反杀失败、S2 认输 | 【必须】 |

> 这 5 个表情替换现有 `yi_nanxing/` 同名文件（引擎 const 路径会改指向 `robarts/`）。

### 2. Christine Vole（核心证人）— `characters/christine/`
被告之妻，全剧操盘手。冷漠如结冰的湖面。**表情反差是 S3/S4 的戏眼**：

| 文件 | 表情 | 触发场景 | 优先级 |
|---|---|---|---|
| `normal.png` | 冷漠/居高临下 | S2/S3 默认 | 【必须】 |
| `shaken.png` | 动摇/脸色骤变 | S3 被信件击破（关键反转） | 【必须】 |
| `smile.png` | 极淡的、掌控一切的笑 | S4 揭穿真相 | 【高价值】 |

### 3. Leonard Vole（被告）— `characters/leonard/`
26 岁退伍青年，外表无辜，真凶。**前后反差**：

| 文件 | 表情 | 触发场景 | 优先级 |
|---|---|---|---|
| `nervous.png` | 局促无辜 | S0 初见、S2 被指证喊"Romaine" | 【必须】 |
| `smug.png` | 得意/露真面目 | S4 抛弃 Christine | 【必须】 |
| `joy.png` | 狂喜松懈 | S3 无罪释放扑栏杆 | 【高价值】 |

> S4 中刀将死那拍用旁白 + 演出处理，**不强制**单独立绘。

### 4. Janet MacKenzie（S1 证人）— `characters/janet/`
21 年老管家，听力受损，把怨恨当事实。

| 文件 | 表情 | 触发场景 | 优先级 |
|---|---|---|---|
| `normal.png` | 笃定带怨 | S1 默认 | 【必须】 |
| `broken.png` | 颤抖/破碎 | S1 证词被击破 | 【必须】 |

### 5. 助理 Mayhew — `characters/mayhew/`
事务所律师，沉稳务实，全剧常驻旁白节奏。

| 文件 | 表情 | 触发场景 | 优先级 |
|---|---|---|---|
| `normal.png` | 沉稳 | 默认 | 【必须】 |
| `shocked.png` | 凝重/惊 | S1 报"她是控方证人"、S4 冲进来 | 【可选】 |

### 6. Wainwright 法官 — `characters/judge/`

| 文件 | 表情 | 优先级 |
|---|---|---|
| `normal.png` | 威严中立 | 【必须】 |

### 7. 检察官 Myers — `characters/myers/`

| 文件 | 表情 | 优先级 |
|---|---|---|
| `normal.png` | 老练咄咄 | 【必须】 |

### 8. 神秘女人（S2 outro）— `characters/mystery_woman/`
真相是 Christine 乔装。**用裹围巾的阴影剪影，不能暴露是 Christine**。

| 文件 | 表情 | 优先级 |
|---|---|---|
| `normal.png` | 阴影剪影/侧逆光 | 【高价值】（缺则用纯文字+黑屏） |

### 9. 陪审团主席 — 无需立绘
仅 1 句"无罪"，纯文字呈现（或借背景群像），**不做立绘**。

---

## 三、背景清单 — `backgrounds/`

| 文件 | 场景 | 对应 Stage | 优先级 |
|---|---|---|---|
| `office.png` | 律师事务所（下午，沉郁书卷气） | S0 | 【必须】 |
| `courtroom.png` | 中央刑事法庭（庄严，被告席/证人席/陪审席） | S1 / S2 / S3 | 【必须】 |
| `courtroom_empty.png` | 同一法庭，人去庭空、灯渐熄 | S4 终幕 | 【高价值】（缺则引擎把 courtroom 调暗替代） |

> 现有 `cafeteria_courtroom.png`（食堂法庭）作废。

---

## 四、特效 — `effects/`

| 文件 | 用途 | 优先级 |
|---|---|---|
| `objection.png` | 举证爆闪大字。英伦版建议「**Objection!**」英文，替换现有日式「異議あり！」 | 【高价值】（缺则暂用现有） |

---

## 五、引擎接入约定（命名 → 代码映射）

为支持上述素材，引擎需做两处改造（**待你批准后再写代码**）：

### A. 分场景背景（per-stage bg）
- 每个 Stage 数据加字段 `"bg": "office" / "courtroom" / "courtroom_empty"`
- `main.gd` 建 `BACKGROUNDS` 映射表，`_start_stage` 按 stage 的 `bg` 切换 `_bg.texture`
- 缺图回退：未指定或加载失败 → 沿用上一张

### B. 证人肖像系统（新功能，改动最大）
- **角色注册表**：`speaker 显示名 → {角色id, 默认表情}`，例：`"Christine" → {"christine", "normal"}`、`"Janet MacKenzie" → {"janet", "normal"}`
- **显示逻辑**：DIALOG/证词推进时按当前 speaker 切换立绘；旁白 `"—"` 时立绘淡出；主角侧（Robarts/Mayhew）走右，证人侧走左（具体布局方案在实现阶段定）
- **表情切换**：默认用注册表默认表情；支持台词行可选 `"emotion": "shaken"` 覆盖；特殊触发——击破成功时证人自动切 `broken`/`shaken`，举证时 Robarts 切 `pointing`
- **降级**：某角色/表情缺图 → 回退到该角色 `normal`，再缺 → 不显示立绘（纯文字），**绝不崩**

> B 是和当前"只有主角单立绘"完全不同的展示架构，复杂度类似当初 S2-4 的引擎改造。**（已实装：证人肖像系统 + 分场景背景 + 色块占位 + 缺图回退，见 `scripts/main.gd`。）**

### C. ⚠️ 接图硬性流程（务必遵守）
引擎用 `ResourceLoader.exists` + `load` 加载真图，依赖的是 **Godot 导入产物**（`*.png.import` 兄弟文件 + `.godot/imported/*.ctex`），不是磁盘上的 png 本身。所以：

1. 把真图按 `characters/<id>/<emotion>.png`、`backgrounds/<key>.png` 命名放进对应目录；
2. **必须用 Godot 编辑器打开工程一次**（或跑 `godot --headless --import`）生成 `.import`，并把 `.import` 一并提交；
3. 否则：① 导出发行版不会打包该图；② 运行时可能"存在但加载失败"——引擎已做兜底（回退占位 + `push_warning` 提示），不会崩，但你会看到色块而非真图，留意控制台 warning 区分"路径错"还是"没导入"。

> 当前 9 个角色目录与 3 张背景**均不存在**，游戏全程走色块占位 + 食堂占位背景；你按上述流程补图并导入后，对应立绘/背景即自动生效，无需改代码。

---

## 六、给图生成的提示词

**每个素材的完整可粘贴提示词见 → [art-prompts.md](art-prompts.md)**（含全局风格锚点、各角色锚点、逐表情提示词、一致性工作流、MJ/SD/国产工具适配、神秘女人保密要点）。

要点速记：
- 统一风格锚点：`1950s London, oil-painting / film-still aesthetic, muted desaturated, dramatic chiaroscuro, painterly`
- 同一角色多表情务必**同一画风/同一构图/同一光源**，仅改神态——用基准图 + MJ `--cref` / SD 固定 seed+参考图复用人设，避免穿帮
- 神秘女人**必须阴影剪影、不露五官**，绝不能暴露是 Christine 乔装

---

## 七、最小可玩的素材门槛（建议先凑齐这批）

若想尽快看到英伦化全流程，先备齐【必须】项即可跑通：
- Robarts × 5、Christine × 2（normal/shaken）、Leonard × 2（nervous/smug）、Janet × 2（normal/broken）、Mayhew/judge/myers 各 1
- 背景：office + courtroom（empty 用 courtroom 调暗顶上）
- 特效：暂用现有 objection

合计 **15 张立绘 + 2 张背景**，即可完成英伦化首版；其余【高价值】项后续补强。

---

*创建：2026-06-03 — 美术范围定为完整逆转裁判式（主角 + 分场景背景 + 证人立绘）。引擎接入（per-stage bg + 证人肖像系统）待方案审批。*
