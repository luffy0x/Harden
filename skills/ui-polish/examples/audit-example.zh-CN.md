# 走查示例 — 某求职知识库站点（Next.js 16 + Tailwind CSS 4）

这是本 skill 在一个中文求职知识库站点上的真实走查输出。所有数值均为浏览器内实测（计算样式 / bounding box），不是估算。对比度由 OKLCH token 数学计算得出（OKLCH → 线性 sRGB → WCAG 2.x 公式）。

**Phase 0 探测到的上下文**：设计 token 在 `src/app/globals.css`（`--background`、`--primary`、间距/圆角变量）；`.dark` class + next-themes 双主题；测试断点 375/768/1024/1440；验证命令 `pnpm lint` / `pnpm typecheck` / `pnpm test:e2e`；走查页面：首页、分类列表（含强制触发的空态）、内容详情、投稿目录、投稿表单。

---

## 走查报告 — 首页 + 全站壳层，2026-09-10

### P0（阻断体验 / 违反硬性规范）

- [ ] **全局 focus ring 从未生效。** `:focus-visible { outline: 2px solid var(--primary) }` 有定义，但具体性只有 0-1-0——Tailwind v4 preflight 的重置在 `a`/`button` 上获胜。键盘聚焦的导航链接实测 outline 为 `none 0px`。
      证据：Tab 后 `el.matches(":focus")` 为 true，computed `outlineStyle: none`
      位置：`src/app/globals.css:117`
      修复：`a:focus-visible, button:focus-visible, [tabindex]:focus-visible { ... }`

- [ ] **移动端导航链接塌成 44×90px 竖条。** 375px 下打开导航面板，每个链接逐字竖排、高 90px。原因：`.mobile-nav__panel` 在 flex header 内处于正常流，宽度继承自触发按钮（44px）而非 header。
      证据：bounding box 实测 `面经记录 44x90`、`学习资料 44x90`……共 5 条；面板总高 483px
      位置：`src/app/globals.css` `.mobile-nav__panel`
      修复：`position: absolute; left: 0; right: 0; top: 100%`（offset parent 是 sticky header）+ 链接加 `min-width: 0`

- [ ] **375px 下全站横向溢出 11px。** `scrollWidth - clientWidth = 11`。来源：`.site-header__inner` gap 10px + 品牌区 175px + 主题切换 44px + 投稿按钮 66px = 295px，加上容器两侧 32px 边距后超出 328px 容器。
      证据：元素扫描 → `.site-header__actions` 右缘在 x=371（视口 360）
      位置：`src/app/globals.css:335-352`
      修复：≤640px 时 gap 10px → 8px

### P1（明显粗糙）

- [ ] header 主 CTA（「投稿」）完全没有 `:hover` 规则——全站唯一的主动作按钮是惰性的。
- [ ] 交互元素（主题切换、导航链接、卡片标题链接）无显式 `transition`——hover 变色是瞬时跳变。
- [ ] `.category-filters` 在 375px 保留 18px 卡片 padding，挤压视口边缘。→ 14px。
- [ ] 投稿表单：空提交依赖浏览器原生气泡，但焦点没有移到第一个无效字段。→ `formEl.checkValidity()` 守卫 + `formEl.querySelector(":invalid").focus()`。

### P2（抛光级）

- [ ] Hero 主标题 48px 时 `letter-spacing: -0.03em`——对中文为主的内容偏紧。→ `-0.02em`。
- [ ] `.home-hero__actions { margin-top: 30px }`——全站唯一不在间距 token 上的值。→ `32px`。

### 已验证无问题

- 对比度（双主题数学计算）：10 组前景/背景组合 5.11–16.98，全部 ≥ WCAG AA 4.5:1
- 字阶克制（13/14/16/17/20/28/48px），字重 400–700 分工清晰
- 768px 与 1024px：零横向溢出；分类网格 3→4 列自适应正确
- 主要触控目标全部 ≥ 44×44px；空态带恢复操作；搜索对话框自动聚焦、Escape 关闭
- 动效：统一 `cubic-bezier(0.16,1,0.3,1)`，120–160ms，`prefers-reduced-motion` 全局降级存在
- 无远程字体；仅 sticky header 一处克制的 `backdrop-filter`

---

## 修复后验证（节选）

| 问题 | 修复前 | 修复后 |
|---|---|---|
| 375px 横向溢出 | 11px | 0px |
| 移动导航链接盒模型 | 44×90（逐字竖排） | 328×48 |
| focus-visible 规则级联 | 未生效 | 命中 `a`、`button`、`[tabindex]` |

`pnpm lint`：0 error · `pnpm typecheck`：通过
