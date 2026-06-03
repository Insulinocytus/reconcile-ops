# ReconcileOps

Minimal rules for humans. Continuous reconciliation by AI.

## 核心理念

ReconcileOps 是一套低规则、AI 归整的团队协作方法。它不假设人类会持续正确地维护流程，而是让真实工作留下足够痕迹，再由 AI 持续审查、归类、补偿和校正。三层底线：任何工作服务于有期限的可验证完成定义（L1），任何变更映射到它影响的 Capability Scope（L2），任何推进项目的实际变更通过 PR 并挂载 Goal、Scope、Decision Owner（L3）。

## 能够解决的问题

- 目标只有方向没有完成定义，无法判断何时完成
- 变更绕过审查，审查权没有按能力域分配
- 大量工作无法追踪，PR 脱离目标长期隐形
- 文档债、孤儿 PR、实现与验收标准的偏差无人发现
- 团队混乱长期不可见、不可修复

## 全技能列表

| 技能 | 一句话介绍 |
|------|-----------|
| `rco-setup` | 初始化仓库的 .reconcile-ops 目录、工具依赖和配置 |
| `rco-distill-req` | 将会议纪要、Slack、邮件等脏输入提炼为干净的需求文档 |
| `rco-define-goal` | 从需求文档定义有唯一 ID 和验收标准的 Goal 文档 |
| `rco-create-goal-issue` | 为缺少 GitHub Issue 的 Goal 文档创建 Issue |
| `rco-create-adr-issue` | 遇到技术决策时创建 ADR Issue |
| `rco-create-adr-md` | 将已关闭的 ADR Issue 结论汇总到 docs/adr.md |
| `rco-create-pr` | 将 ReconcileOps 文档变更提交为 PR |

## 各技能 Workflow

### rco-setup

将 `assets/.reconcile-ops/` 复制到项目根目录 → 读取 config.json → 检查并安装 gh/jq/rg/curl/mise → 初始化 mise 到 ~/.zshrc → 询问分支前缀 → 写入 config.json → 验证配置。

### rco-distill-req

读取 config.json → 若无输入则列出支持格式并建议访谈 → 识别业务主题 → 扫描已有需求文档 → 匹配则合并更新，不匹配则新建 → 写入四段（Situations / Needs / Doesn't Need / Pending Confirmation）→ 报告待确认数量 → 询问是否继续 rco-define-goal 或先 rco-create-pr。

### rco-define-goal

读取 config.json → 读取源需求 → 判断需求是否足够明确 → 扫描已有 Goal ID → 分配下一个不重复 ID → 创建 docs/goals/G-*.md（来源需求、验收标准）→ 废弃时加 Superseded 标记 → 提醒运行 rco-create-pr 和 rco-create-goal-issue。

### rco-create-goal-issue

读取 config.json → 扫描 docs/goals/ → 解析每个 G-*.md 的标题 → 搜索是否已有 [G-XXXXXX] 标题的 Issue → 创建 Issue（Goal 链接 + PRs 段）并加入 GitHub Project → Superseded 的 Goal 设 Issue 状态为 Superseded。

### rco-create-adr-issue

遇到技术决策 → 扫描已有 ADR Issue 编号 → 分配下一个 ID → 创建 Issue（Consequences / Context / Decision / Supersedes）→ 加 adr label。

### rco-create-adr-md

扫描所有 ADR Issue → 提取已关闭 Issue 的 Consequences → 汇总到 docs/adr.md（Active + Superseded + Pending）→ 提醒运行 rco-create-pr。

### rco-create-pr

读取 config.json → 检查变更文件 → 按路径生成 PR 摘要 → 从 config.json 读取分支前缀 → 创建分支 → 仅暂存相关文件 → 提交 → 创建 PR → 如果涉及 Goal 变更则更新对应 Issue 的 PRs 段 → 报告 URL 和变更文件。
