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
| `rco-define-goal` | 从需求文档定义有唯一 ID、可验证完成定义的 Goal 文档 |
| `rco-create-spec` | 从需求或 Goal 文档创建工程规格说明（行为、接口、数据契约等） |
| `rco-create-issue` | 为缺少 GitHub Issue 的 Goal 文档创建 Issue 并更新映射表 |
| `rco-create-pr` | 将 ReconcileOps 文档变更提交为 PR，描述由变更文件路径自动生成 |
| `rco-nightly-inspect` | 合并后巡检：发现孤儿 PR、缺失 Issue 的 Goal、不完整 Goal、过期 Goal、文档债、缺少 Scope/Decision Owner 的 PR、停滞 Issue |

## 各技能 Workflow

### rco-setup

将 `assets/.reconcile-ops/` 复制到项目根目录 → 读取 config.json → 检查并安装 gh/jq/rg/curl/mise → 初始化 mise 到 ~/.zshrc → 询问分支前缀 → 写入 config.json → 验证配置。

### rco-distill-req

读取 config.json → 读取示例结构 → 若无输入则列出支持格式并建议访谈 → 识别业务主题 → 仅写入稳定内容（背景、客户希望、客户不需要、约束）→ 未确认问题报告在响应中不写入 Git → 询问是否继续 rco-define-goal 或先 rco-create-pr。

### rco-define-goal

读取 config.json → 读取示例结构 → 读取源需求 → 判断需求是否稳定可验证 → 扫描已有 Goal ID（文件 + 映射表 + Git 历史）→ 分配下一个不重复 ID → 创建 docs/goals/G-*.md（目标、来源需求、客户意图、交付物、验收标准、验证方法）→ 提醒运行 rco-create-pr。

### rco-create-spec

读取 config.json → 读取示例结构 → 读取输入需求或 Goal → 跟踪需求与 Goal 之间的链接 → 识别业务领域和输出路径 → 调用相关工程技能（API 设计、安全、数据库等）→ 写入 docs/specs/<business-area>/<capability-or-flow>.md → 提醒运行 rco-create-pr。

### rco-create-issue

读取 config.json → 读取示例结构 → 扫描 docs/goals/ → 解析每个 G-*.md 的标题 → 检查是否已有对应 Issue → 创建 [G-000001] Goal Title 格式的 Issue → 加入 GitHub Project → 仅在 GOAL_ISSUE_MAP.json 记录 goal id → issue id 映射。

### rco-create-pr

读取 config.json → 读取示例结构 → 检查变更文件 → 按路径生成 PR 摘要 → 从 config.json 读取分支前缀 → 创建分支 → 仅暂存相关文件 → 提交 → 创建 PR → 报告 URL 和变更文件。

### rco-nightly-inspect

读取 config.json → 读取 inspect_stale_days（默认 14）→ 收集所有开放 PR 和 Goal 文件 → 逐项检查：孤儿 PR（无 Goal 引用）、Goal 无 Issue、Goal 缺少 L1 必填段、Goal 过期、文档债（需求无 Goal / Goal 无 Spec / Spec 无 PR）、PR 缺少 Scope 或 Decision Owner、停滞 Issue → 汇总为结构化报告写入 .reconcile-ops/nightly-inspect-report.md → 可选 --create-issues 为高优先级发现创建 Issue → 报告总发现数和报告路径。
