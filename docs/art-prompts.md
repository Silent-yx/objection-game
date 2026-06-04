# 生图提示词总表 — 《控方证人》英伦版（GPT Image 2 · 罗小黑画风）

> 配套 [art-assets.md](art-assets.md)。格式：**素材名（落位路径）：完整提示词**，自然语言、自包含、可直接粘贴给 GPT Image 2。
> **全套统一画风 = 《罗小黑战记》式干净扁平国漫**，承载 1950s 英伦法庭题材（清爽画风 × 严肃案件，逆转裁判式反差）。
> 生成后按路径命名落位、**在 Godot 里导入生成 `.import`**。

---

## ★ 全局风格基准（Global Style Baseline）

参考《罗小黑战记》(The Legend of Hei)。拆成可执行特征：

| 维度 | 基准 |
|---|---|
| 线条 | **粗而干净的单线勾勒**，线条简练凝实，靠线本身表现神态动作 |
| 上色 | **大色块平涂**，弱阴影 / 接近无阴影（cel 风），立体感靠造型不靠明暗 |
| 造型 | 简约、干净、略带童趣，但精致考究（"deceptively simple yet refined"） |
| 配色 | 柔和、和谐、清新；整体偏暖治愈，**冷暗氛围靠场景光与神态营造，而非脏暗滤镜** |
| 背景 | 偏**水彩 + 中式水墨意境**，柔和全景，比角色更"画"一些（扁平角色 × 水彩背景的反差） |
| 整体 | 扁平、图形化，**非写实、非油画、非厚涂**；宫崎骏 / 京阿尼式 2D 流畅清爽 |

**英文风格句（已内置到每条提示词末尾，全套统一这一串）：**
- 角色：
  ```
  Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle, deceptively-simple look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D, no harsh gritty rendering.
  ```
- 背景：
  ```
  Art style: a clean 2D animation background inspired by The Legend of Hei (罗小黑战记) — soft watercolour washes with gentle gradients and a light touch of Chinese ink-painting atmosphere, simple flat shapes, a harmonious palette, calm and uncluttered. Flat and graphic, NOT photorealistic, NOT 3D.
  ```

### 全局一致性工作流（让整套像出自同一支笔，关键）
1. **先生成"风格锚定图"**（见下方专用提示词），反复挑到一张画风、配色、线条、上色都满意的，存为**全局基准图**；
2. **之后每一张**（不只是同角色多表情，而是所有立绘 + 背景）生成时，**都把这张基准图作为参考图上传**，提示词前面加一句：
   > "Match the exact art style, line weight, flat-colour shading, and colour palette of this reference image."
3. 同角色多表情：再叠加该角色的 `normal` 基准图（双参考：全局风格图 + 角色基准图），只改神态。
4. 锁死四件套：**同线条粗细、同平涂方式、同配色、同扁平度**。

**风格锚定图（先生成它，当全局基准）：**
```
A clean flat 2D animation key illustration in the style of the Chinese film The Legend of Hei (罗小黑战记): an elderly British defense barrister in a black gown and a middle-aged barrister in a short white wig stand in a softly painted 1950s British courtroom. Bold tidy outlines, large blocks of flat colour with little or no shading, a soft harmonious palette, simple elegant character forms, a gentle watercolour background. Flat and graphic, not photorealistic, not oil-painted, not 3D. No text, no watermark.
```
（定调用：锁住线条 / 平涂 / 配色 / 扁平度，后续所有图都参考它）

---

## 通用项（GPT Image 2 专属）

- **自然语言**：GPT Image 2 吃完整句子，不用 `--ar`/tag。下面每条已写好，直接粘贴。
- **尺寸**：立绘 → **1024 × 1536（竖）**；背景 → **1536 × 1024（横）**。
- **透明背景**：立绘原生透明。API 设 `background:"transparent"` + `format:"png"`；网页里靠正文 "transparent background"。每条立绘末尾已含。
- **无负面提示词字段**：排除项写进正文（每条末尾已附"不要文字/水印/边框/现代物件/写实厚涂"）。
- **一致性**：见上方"全局一致性工作流"——核心是**每张都挂全局基准图当参考**。

---

## 立绘（1024 × 1536，透明背景，挂全局基准图当参考）

**robarts/normal.png：**
```
A half-body character portrait of Sir Wilfrid Robarts, a distinguished British defense barrister in his sixties: a lean intelligent face, receding silver-grey hair, wearing a black barrister's gown over a stiff wing-collar shirt. His expression is calm and composed, with a scrutinizing gaze and a faint stern frown. The figure is centered and faces slightly to the left, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle, deceptively-simple look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（平静审视 · 默认 → 设为角色基准图）

**robarts/thinking.png：**
```
A half-body character portrait of Sir Wilfrid Robarts, a distinguished British barrister in his sixties: lean intelligent face, receding silver-grey hair, black barrister's gown over a wing-collar shirt. His expression is pensive and thoughtful — eyes lowered in concentration, one hand raised near his chin, deep in thought. The figure is centered and faces slightly to the left, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（沉思 · 翻证据时）

**robarts/pointing.png：**
```
A half-body character portrait of Sir Wilfrid Robarts, a distinguished British barrister in his sixties: lean intelligent face, receding silver-grey hair, black barrister's gown over a wing-collar shirt. He is leaning forward, one arm raised with the index finger pointing straight ahead, a fierce determined glare, mouth open mid-shout as if making an objection — a dynamic pose. The figure is centered and faces slightly to the left, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（前倾指证 · 举证爆发）

**robarts/shocked.png：**
```
A half-body character portrait of Sir Wilfrid Robarts, a distinguished British barrister in his sixties: lean intelligent face, receding silver-grey hair, black barrister's gown over a wing-collar shirt. He is taken aback — eyes wide with shock, eyebrows raised, body recoiling slightly, an expression of stunned disbelief. The figure is centered and faces slightly to the left, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（震惊 · 反水/真相时）

**robarts/nervous.png：**
```
A half-body character portrait of Sir Wilfrid Robarts, a distinguished British barrister in his sixties: lean intelligent face, receding silver-grey hair, black barrister's gown over a wing-collar shirt. His expression is grim and strained — jaw tight, brow furrowed in unease, the look of a man cornered. The figure is centered and faces slightly to the left, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（凝重受挫 · 挫败/认输时）

**christine/normal.png：**
```
A half-body character portrait of Christine Vole, an elegant enigmatic European woman in her early thirties: a calm composed face, dark hair smoothly pulled back, wearing an elegant dark 1950s dress. Her expression is cool and unreadable, calm as a frozen lake, with a distant detached gaze. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle, deceptively-simple look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（冷漠如结冰的湖面 · 默认 → 设为角色基准图）

**christine/shaken.png：**
```
A half-body character portrait of Christine Vole, an elegant European woman in her early thirties: a pale composed face, dark hair pulled back, an elegant dark 1950s dress. Her composure is cracking for the first time — eyes widening in alarm, lips parted, a flicker of panic and disbelief, leaning back slightly. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（第一次动摇 · 被信件击破，关键）

**christine/smile.png：**
```
A half-body character portrait of Christine Vole, an elegant European woman in her early thirties: a composed face, dark hair pulled back, an elegant dark 1950s dress. She wears a faint, cool, knowing smile at the corner of her mouth, eyes glinting with quiet triumph and control — utterly composed, the look of someone who planned everything. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（掌控一切的冷笑 · 终幕揭穿）

**leonard/nervous.png：**
```
A half-body character portrait of Leonard Vole, a young man of twenty-six with a boyish, handsome, ordinary face and light tousled hair, wearing a worn but neatly kept suit — a former soldier down on his luck. His expression is anxious and pleading — uneasy, with wide imploring eyes, slightly hunched. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle, deceptively-simple look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（局促哀求 · S0 初见 / S2 被指证 → 设为角色基准图）

**leonard/smug.png：**
```
A half-body character portrait of Leonard Vole, a young man of twenty-six with a boyish handsome face and light tousled hair, wearing a worn neat suit. He wears a cruel, self-satisfied smirk with cold arrogant eyes, relaxed and triumphant, chin slightly raised — his true callous nature revealed. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（得意露真面目 · S4 抛弃 Christine）

**leonard/joy.png：**
```
A half-body character portrait of Leonard Vole, a young man of twenty-six with a boyish handsome face and light tousled hair, wearing a worn neat suit. He is overjoyed and relieved — tearful grateful eyes, a broad emotional smile, hands clasped, leaning forward in elation. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（狂喜含泪 · S3 无罪释放）

**janet/normal.png：**
```
A half-body character portrait of Janet MacKenzie, a stout elderly Scottish housekeeper in her sixties: a plain kindly-but-stern face, grey hair pulled into a tight bun, wearing a modest dark high-collar dress with a white collar. Her expression is resolute and resentful — lips pursed tight, righteous and unyielding. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（笃定带怨 · 默认 → 设为角色基准图）

**janet/broken.png：**
```
A half-body character portrait of Janet MacKenzie, a stout elderly Scottish housekeeper in her sixties: a plain face, grey hair in a tight bun, a modest dark high-collar dress. She is flustered and distressed — trembling lips, eyes glistening and uncertain, faltering, one hand half-raised in agitation. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（慌乱颤抖 · 证词被击破）

**mayhew/normal.png：**
```
A half-body character portrait of Mr. Mayhew, a tidy middle-aged British solicitor in his fifties: neat receding hair, round spectacles, a dark three-piece suit, holding a folder of documents. His expression is calm, steady and composed, with an attentive professional gaze. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（沉稳专注 · 默认）

**mayhew/shocked.png（可选）：**
```
A half-body character portrait of Mr. Mayhew, a tidy middle-aged British solicitor in his fifties: neat receding hair, round spectacles, a dark three-piece suit. His expression is startled and grave — eyes widened behind his spectacles, lips parted in concern. The figure is centered and faces slightly to the right, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — inspired by The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（惊愕凝重 · S1 报"控方证人"/S4 冲进来）

**judge/normal.png：**
```
A half-body character portrait of Justice Wainwright, a stern elderly British judge wearing the traditional scarlet judicial robe and a long ceremonial white horsehair wig. His expression is authoritative and solemn, with a grave impartial gaze, seated upright. The figure is centered and faces forward, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（猩红法袍 + 白马毛假发 · 威严中立）

**myers/normal.png：**
```
A half-body character portrait of Mr. Myers, a sharp middle-aged British prosecuting barrister with a lean shrewd face, wearing a black barrister's gown and a short white horsehair wig. His manner is crisp, confident and aggressive — chin slightly raised, a cutting gaze. The figure is centered and faces slightly to the left, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and large blocks of flat colour, little or no shading (cel style), a soft and harmonious palette, simple and elegant — a fresh, gentle look inspired by the Chinese animated film The Legend of Hei (罗小黑战记). Flat and graphic, NOT photorealistic, NOT oil-painted, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（黑袍 + 短假发 · 干练咄咄）

**mystery_woman/normal.png：** ⚠️ 必须阴影剪影、绝不露五官、不能看出是 Christine
```
A half-body figure of a mysterious woman in a shabby worn headscarf and a threadbare coat — a poor London street woman, shown almost entirely as a dark silhouette: her face is hidden in shadow and unreadable, with only a faint sly hint of her mouth barely suggested. Secretive, furtive posture, a cool dim low-key palette, heavy shadow. IMPORTANT: keep her identity hidden — do NOT render clear facial features. The figure is centered, on a fully transparent background with nothing else in the frame. Art style: clean, flat 2D animation with bold tidy outlines and flat colour, simple shapes — inspired by The Legend of Hei (罗小黑战记), but rendered as a shadowed silhouette. Flat and graphic, NOT photorealistic, NOT 3D. Do not include any text, watermark, border, or modern objects.
```
（裹头巾的伦敦街头女人 · 暗色剪影，脸沉在阴影里）

---

## 背景（1536 × 1024，无人物，挂全局基准图当参考）

**backgrounds/office.png：**
```
A clean 2D animation background of the interior of a 1950s London barrister's private law office in the late afternoon: tall wooden bookshelves full of leather law volumes, a heavy oak desk with stacked papers and a green banker's lamp, worn leather armchairs, and a tall window with soft warm light and rain outside. A calm, cozy, bookish mood. The room is empty with no people. A wide 3:2 landscape. Art style: a clean 2D animation background inspired by The Legend of Hei (罗小黑战记) — soft watercolour washes with gentle gradients and a light touch of Chinese ink-painting atmosphere, simple flat shapes, a warm harmonious palette, calm and uncluttered. Flat and graphic, NOT photorealistic, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（律师事务所 · S0）

**backgrounds/courtroom.png：**
```
A clean 2D animation background of the interior of an imposing 1950s British central criminal court (Old Bailey style): carved wood panelling, an elevated judge's bench with the royal coat of arms, a witness box, the prisoner's dock, a jury box, and rows of benches. A solemn, grand atmosphere with soft light from high windows. The courtroom is empty with no people. A wide 3:2 landscape. Art style: a clean 2D animation background inspired by The Legend of Hei (罗小黑战记) — soft watercolour washes with gentle gradients and a light touch of Chinese ink-painting atmosphere, simple flat shapes, a harmonious palette, calm and uncluttered. Flat and graphic, NOT photorealistic, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（中央刑事法庭 · S1/S2/S3）

**backgrounds/courtroom_empty.png：**
```
A clean 2D animation background of the same imposing 1950s British criminal courtroom, now empty after the trial: the lights are dimming, long cool shadows stretch across the deserted benches, and a single pale shaft of light falls through the gloom. A quiet, lonely, melancholic mood. No people. A wide 3:2 landscape. Art style: a clean 2D animation background inspired by The Legend of Hei (罗小黑战记) — soft watercolour washes with gentle gradients and a light touch of Chinese ink-painting atmosphere, simple flat shapes, a muted cool harmonious palette, calm and uncluttered. Flat and graphic, NOT photorealistic, NOT 3D. Do not include any text, lettering, watermark, border, or modern objects.
```
（空荡法庭/终幕 · S4，与 courtroom 同机位最佳）

---

## 特效（透明背景）

**effects/objection.png：**
```
Render the single English word "OBJECTION!" as bold, dynamic, comic-style impact lettering: heavy condensed letters in white with a thick clean coloured outline, set at a dramatic diagonal angle with a simple burst shockwave behind it, high contrast but clean and graphic. Isolated on a fully transparent background with nothing else in the frame. Spell the word exactly as "OBJECTION!" and include no other text.
```
（「OBJECTION!」冲击字 · 干净图形化，GPT Image 2 文字渲染好，必要时重抽挑字形）

---

## 最小批次（先凑这批即可英伦化跑通）

0. **先出"风格锚定图"**（见上方），定调全局画风。
1. 15 张立绘：robarts ×5、christine ×2（normal/shaken）、leonard ×2（nervous/smug）、janet ×2（normal/broken）、mayhew/judge/myers 各 1。
2. 2 张背景：office + courtroom（empty 先用 courtroom 顶上）。特效暂用现有。
> 每张都挂"全局锚定图"作参考；同角色多表情再叠该角色 normal 基准图。抠图裁切 → 按路径命名 → Godot 导入生成 `.import` → 自动生效。

---

*更新：2026-06-03 — 全局画风改为《罗小黑战记》式干净扁平国漫（粗净线条 + 大色块平涂 + 弱阴影 + 柔和配色 + 水彩背景），新增风格锚定图与全局一致性工作流。*
