# 生图提示词总表 — 《控方证人》英伦版

> 配套 [art-assets.md](art-assets.md)。格式：**素材名（落位路径）：完整提示词**，每条自包含、可直接粘贴。
> 英文提示词为主（MJ / SD / DALL·E / 国产工具通吃），风格已揉进每条。生成后按路径命名落位、**在 Godot 里导入生成 `.import`**。

## 通用项（先读一次）

- **负面提示词（所有立绘通用）**：`modern clothing, smartphone, bright neon colors, anime, manga, chibi, cartoon, flat vector, text, watermark, signature, extra fingers, deformed hands, cluttered photographic background, lowres`
- **透明背景**：多数工具不直出，建议平涂中性灰底生成后抠图（remove.bg / PS）。立绘成品 760×1080，背景成品 1280×720。
- **一致性（同角色多表情不穿帮）**：先只生成该角色 `normal` 定为基准图，其余表情复用人设——MJ 加 `--cref <基准图URL> --cw 80`；SD 固定同一 seed + 参考图（IP-Adapter/Reference-Only）；即梦/可灵用"角色参考"。只改神态，锁死同画风/同构图/同光源。

---

## 立绘

**robarts/normal.png：**
```
Sir Wilfrid Robarts, a distinguished elderly British defense barrister in his sixties, gaunt intelligent face, sharp piercing eyes, receding silver-grey hair, black barrister's gown over a wing-collar shirt, slightly pale from illness, calm composed expression with a scrutinizing gaze and a faint stern frown, half-body portrait centered, facing slightly left, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（平静审视 · 默认）

**robarts/thinking.png：**
```
Sir Wilfrid Robarts, a distinguished elderly British defense barrister in his sixties, gaunt intelligent face, sharp eyes, receding silver-grey hair, black barrister's gown over a wing-collar shirt, slightly pale, pensive thoughtful expression with eyes lowered in concentration and one hand raised near his chin deep in thought, half-body portrait centered, facing slightly left, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（沉思 · 翻证据时）

**robarts/pointing.png：**
```
Sir Wilfrid Robarts, a distinguished elderly British defense barrister in his sixties, gaunt intelligent face, sharp eyes, receding silver-grey hair, black barrister's gown over a wing-collar shirt, leaning forward aggressively with one arm raised and index finger pointing straight ahead, fierce triumphant glare, mouth open mid-shout as if objecting, dynamic dramatic low angle, half-body portrait centered, facing slightly left, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（前倾指证 · 举证爆发）

**robarts/shocked.png：**
```
Sir Wilfrid Robarts, a distinguished elderly British defense barrister in his sixties, gaunt intelligent face, sharp eyes, receding silver-grey hair, black barrister's gown over a wing-collar shirt, taken aback with eyes wide in shock, eyebrows raised, body recoiling slightly, stunned disbelief, half-body portrait centered, facing slightly left, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（震惊 · 反水/真相时）

**robarts/nervous.png：**
```
Sir Wilfrid Robarts, a distinguished elderly British defense barrister in his sixties, gaunt intelligent face, sharp eyes, receding silver-grey hair, black barrister's gown over a wing-collar shirt, grim strained expression with jaw tight and brow furrowed in frustration and unease, shadowed troubled eyes, a man cornered, half-body portrait centered, facing slightly left, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（凝重受挫 · 挫败/认输时）

**christine/normal.png：**
```
Christine Vole, an elegant enigmatic European woman in her early thirties, a former German actress, pale composed oval face, dark hair pulled back smoothly, refined cold beauty, an elegant dark 1950s dress, cold unreadable expression calm as a frozen lake, distant detached gaze, theatrical poise, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（冷漠如结冰的湖面 · 默认）

**christine/shaken.png：**
```
Christine Vole, an elegant enigmatic European woman in her early thirties, pale oval face, dark hair pulled back, an elegant dark 1950s dress, her composure cracking for the first time, eyes widening in alarm, lips parted, a flicker of panic and disbelief, leaning back slightly, paler than before, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（第一次动摇 · 被信件击破，关键）

**christine/smile.png：**
```
Christine Vole, an elegant enigmatic European woman in her early thirties, pale oval face, dark hair pulled back, an elegant dark 1950s dress, a faint cold knowing smile curling at the corner of her mouth, eyes glinting with quiet triumph and control, utterly composed, the look of someone who planned everything, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（掌控一切的冷笑 · 终幕揭穿）

**leonard/nervous.png：**
```
Leonard Vole, a young man of twenty-six, boyish handsome ordinary face, light tousled hair, a worn but neatly kept suit, a former soldier down on his luck, anxious pleading expression, fidgety and uneasy, wide imploring eyes, slightly hunched, restless hands, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（局促哀求 · S0 初见 / S2 被指证）

**leonard/smug.png：**
```
Leonard Vole, a young man of twenty-six, boyish handsome face, light tousled hair, a worn neat suit, a cruel self-satisfied smirk, cold arrogant eyes, relaxed and triumphant, his true callous nature revealed, chin slightly raised, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（得意露真面目 · S4 抛弃 Christine）

**leonard/joy.png：**
```
Leonard Vole, a young man of twenty-six, boyish handsome face, light tousled hair, a worn neat suit, overjoyed and relieved, tearful grateful eyes, a broad emotional smile, hands clasped, leaning forward in elation, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（狂喜含泪 · S3 无罪释放）

**janet/normal.png：**
```
Janet MacKenzie, a stout elderly Scottish housekeeper in her sixties, plain weathered face, grey hair in a tight bun, a modest dark high-collar dress with a white collar, resolute resentful expression, lips pursed tight, righteous indignation, certain and unyielding, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（笃定带怨 · 默认）

**janet/broken.png：**
```
Janet MacKenzie, a stout elderly Scottish housekeeper in her sixties, plain weathered face, grey hair in a tight bun, a modest dark high-collar dress, flustered and distressed, trembling lips, eyes glistening and uncertain, faltering confidence, a hand half-raised in agitation, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（慌乱颤抖 · 证词被击破）

**mayhew/normal.png：**
```
Mr. Mayhew, a tidy middle-aged British solicitor in his fifties, neat receding hair, round spectacles, a dark three-piece suit, holding a folder of documents, calm steady composed expression, attentive professional gaze, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（沉稳专注 · 默认）

**mayhew/shocked.png（可选）：**
```
Mr. Mayhew, a tidy middle-aged British solicitor in his fifties, neat receding hair, round spectacles, a dark three-piece suit, startled grave expression, eyes widened behind his spectacles, lips parted in concern, half-body portrait centered, facing slightly right, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（惊愕凝重 · S1 报"控方证人"/S4 冲进来）

**judge/normal.png：**
```
Justice Wainwright, a stern elderly British judge wearing the traditional scarlet judicial robe and a long ceremonial white horsehair wig, authoritative solemn expression, grave impartial gaze, seated upright behind the bench, half-body portrait centered, facing forward, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（猩红法袍 + 白马毛假发 · 威严中立）

**myers/normal.png：**
```
Mr. Myers, a sharp middle-aged British prosecuting barrister, lean shrewd face, a black barrister's gown and a short white horsehair wig, crisp confident and aggressive, chin slightly raised, a cutting gaze, half-body portrait centered, facing slightly left, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, painterly, highly detailed, plain neutral background --ar 2:3
```
（黑袍 + 短假发 · 干练咄咄）

**mystery_woman/normal.png：** ⚠️ 必须阴影剪影、绝不露五官、不能看出是 Christine
```
a mysterious woman in a shabby worn headscarf and a threadbare coat, a cockney London street woman, seen as a backlit silhouette in a dim foggy alley, her face hidden in deep shadow and completely unreadable with only a sly hint of her mouth faintly visible, secretive furtive posture, low-key near-black palette, strong rim backlight, heavy darkness, half-body portrait centered, 1950s London, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro heavy shadow, soft film grain, painterly, plain neutral background --ar 2:3
```
（裹头巾的伦敦街头女人 · 逆光剪影，脸沉在黑暗里）

---

## 背景（16:9，无人物，不透明）

**backgrounds/office.png：**
```
interior of a 1950s London barrister's private law office, late afternoon, tall dark wooden bookshelves crammed with leather law volumes, a heavy oak desk stacked with papers and a green banker's lamp, worn leather armchairs, a tall window with dusty golden light and rain outside, somber bookish solemn atmosphere, no people, empty room, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, highly detailed --ar 16:9
```
（律师事务所 · S0）

**backgrounds/courtroom.png：**
```
interior of an imposing 1950s British central criminal court in the Old Bailey style, dark carved wood panelling, an elevated judge's bench with the royal coat of arms, a witness box, the prisoner's dock, a jury box, rows of benches, solemn grand intimidating atmosphere, shafts of dramatic light from high windows, no people, empty courtroom, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, dramatic chiaroscuro lighting, soft film grain, highly detailed --ar 16:9
```
（中央刑事法庭 · S1/S2/S3）

**backgrounds/courtroom_empty.png：**
```
the same imposing 1950s British criminal courtroom but now utterly empty after the trial, house lights dimming, long cold shadows stretching across the deserted benches, a single lingering shaft of pale light, an air of loneliness and dread, melancholic haunting mood, no people, classic oil-painting and vintage film-still aesthetic, muted desaturated palette, very dark low-key chiaroscuro lighting, soft film grain, highly detailed --ar 16:9
```
（空荡法庭/终幕 · S4，与 courtroom 同机位最佳）

---

## 特效（透明背景）

**effects/objection.png：**
```
the single English word "OBJECTION!" as bold dynamic comic impact lettering, heavy condensed impact serif font, white letters with a thick red-and-black outline and a sharp burst shockwave behind, dramatic diagonal angle, high contrast, isolated on a fully transparent background, vintage courtroom-drama flair --ar 16:9
```
（「OBJECTION!」冲击字 · 含文字易出错，多抽几张挑字形，或用设计软件排版更稳）

---

## 最小批次（先凑这批即可英伦化跑通）

15 张立绘：robarts ×5、christine ×2（normal/shaken）、leonard ×2（nervous/smug）、janet ×2（normal/broken）、mayhew/judge/myers 各 1。
2 张背景：office + courtroom（empty 先用 courtroom 顶上）。特效暂用现有。
生成 → 抠图裁切 → 按路径命名 → Godot 打开工程一次生成 `.import` → 自动生效。

---

*更新：2026-06-03 — 改为「素材名：提示词」扁平格式，每条自包含可直接粘贴。*
