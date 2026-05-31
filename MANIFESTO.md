# ReconcileOps：一套低规则、AI 归整的团队协作方法

团队协作的核心问题，通常被包装成流程问题、管理问题、文档问题、进度问题。很多方法会尝试设计更完整的流程、更细的角色、更严格的文档模板、更复杂的看板字段。但现实中的团队很少像流程图那样运转。

人会临时改主意，会先写代码再补说明，会跳过看板，会在 Slack 里做决定，会忘记更新文档，会因为紧急问题绕过原有路径。AI Agent 也一样，它可能漏读上下文、过度执行、提前收工、误判任务边界。一个团队系统如果依赖所有参与者持续、正确、完整地遵守规则，它天然脆弱。

**ReconcileOps 的出发点是：降低人类必须遵守的规则，把混乱后的审查、归类、补偿、校正交给 AI。**

它追求的目标是：

> 人类只遵守最低协作底线，AI 持续把真实工作中的混乱归整为可追踪、可验证、可推进的状态。

## 一、团队协作的最低底线

ReconcileOps 先定义团队协作中真正需要坚守的底线。规则越少，人越容易遵守；底线越硬，系统越容易恢复。

这套底线分为三层。

## L1：Deadline + 可验证完成定义

团队协作的最底层目标是：

> 在给定期限内，交付一个可被验证为完成的结果。

这里的 Goal 必须被压实成可验证的完成定义。一个有效目标至少包含：

```txt
Deadline
Deliverable
Acceptance Criteria
Verification Method
```

也就是：

```txt
什么时候交付
交付什么
满足什么条件算完成
如何验证已经完成
```

团队里最危险的目标，是只有方向感、缺少完成定义的目标。比如“优化系统”“改善文档”“完成基础设施建设”都太松散。它们可以作为意图，但进入执行前必须变成可验证结果。

ReconcileOps 中的第一条底线是：

> 任何有效工作都必须服务于一个有期限、可验证的完成定义。

## L2：Capability Scope

传统团队管理经常按上下级、职位、汇报线分配责任。但真实工作中，判断权往往来自能力域。

一个 AWS 相关变更，应该让懂 AWS 的人参与 review；一个安全相关变更，应该让懂安全的人参与裁决；一个数据库 schema 变更，应该让懂 DB 的人介入。这里的关键是能力域，而不是职位。

ReconcileOps 把人的作用域定义为 Capability Scope。

常见 Scope 可以包括：

```txt
Frontend
Backend
Database
AWS
Security
Product
Docs
QA
Release
```

每个 Goal、PR、决策都需要识别它影响了哪些 Scope。影响某个 Scope 的变更，就应该让对应 Scope 的人拥有 review、approve、block、escalate 的权力。

这层的底线是：

> 任何影响特定能力域的变更，都必须让对应能力域的人拥有审查权。

如果一个 PR 修改了 Goal、验收标准、期限或范围，它还需要加入拥有 Goal 决定权的人 review。实现层面的裁决归 Capability Owner，目标层面的裁决归 Goal Decision Owner。

## L3：PR as Trace Anchor

ReconcileOps 把 PR 定义为唯一闸门，也是最小 Trace Anchor。

任何能推动项目向 Goal 前进的 PR 都是有效 PR。任何找不到对应 Goal 的 PR 都是高风险信号。它说明有人正在做脱离目标的工作，或者现有 Goal 无法覆盖真实需求。这两种情况都需要被抬出来审查。

每个 PR 必须回答三个问题：

```txt
它推进哪个 Goal？
它影响哪些 Capability Scope？
它需要谁来裁决？
```

PR 可以同时修改 Goal 和实现 Goal。现实开发中，很多细节只有进入实现阶段才会浮现。强制所有目标变更都提前拆成独立流程，会提高沟通成本，也会降低系统的灵活性。

因此，ReconcileOps 允许 Mixed PR：

```txt
Implementation PR：只实现既定 Goal
Goal Change PR：修改 Goal / 验收标准 / 期限 / 范围
Mixed PR：同时修改 Goal 和实现 Goal
```

当 PR 修改实现时，它需要相关 Capability Scope 的 review。
当 PR 修改 Goal 时，它需要 Goal Decision Owner 的 review。
当 PR 同时修改 Goal 和实现时，它同时满足这两类 review。

L3 的底线是：

> 任何推进项目的实际变更都必须通过 PR，并在 PR 中挂载 Goal、Scope、Decision Owner。

## 二、ReconcileOps 的核心思想

ReconcileOps 的核心可以压缩成一句话：

> Minimal rules for humans. Continuous reconciliation by AI.

人类只需要遵守三件事：

```txt
写清楚目标
找对能力域
通过 PR 留痕
```

剩下的工作由 AI 辅助完成：

```txt
检查 PR 是否关联 Goal
检查 Goal 是否具备可验证完成定义
识别 PR 影响的 Capability Scope
判断 reviewer 是否覆盖必要能力域
发现 orphan PR
发现文档债
发现目标变更
发现实现与验收标准的偏差
生成补偿任务
更新状态视图
提醒需要人类裁决的问题
```

这套系统承认真实团队会混乱。它的重点是让混乱可以被捕获、被归类、被修复。

## 三、Git 管成果，GitHub 管状态，AI 管归整

Git 很适合管理稳定成果物，比如：

```txt
spec
ADR
architecture docs
skills
code
workflow config
```

状态变化频率很高，比如任务是否 blocked、谁正在处理、当前 review 是否完成、文档是否欠债。把这些状态全部放进 Git，会制造大量低价值 PR。

ReconcileOps 的分工是：

```txt
Git：管理长期成果物
PR：承载实际变更和 Trace Anchor
GitHub Project / Label / Check：承载轻量状态
AI：持续审查、归类、补偿、校正
```

PR 是闸门。Project board 是状态视图。Docs 是沉淀成果。AI Agent 是 reconciliation 层。

## 四、AI Skill 的正确位置

一开始很容易想做一个巨大的 AI Skill 包，把开发团队和管理团队的所有日常工作全部打包进去。但人的行为太灵活，所有日常动作都很难被提前预测。

ReconcileOps 中，Skill 的职责从“规定人怎么工作”转为“整理人已经做过的事”。

AI Skill 更适合承担这些稳定任务：

```txt
PR Reconciliation
Goal Validation
Scope Detection
Reviewer Routing
Doc Debt Detection
ADR Suggestion
Orphan PR Detection
Release Readiness Check
Project Status Sync
```

这类 Skill 的共同点是：输入来自已有事实，输出用于修复协作状态。

它们不会要求人完全按流水线行动。它们负责在事后把真实行动归整回系统可以理解的结构。

## 五、为什么这套方法鲁棒

ReconcileOps 的鲁棒性来自三个设计选择。

第一，规则足够少。人类只需要保证目标清楚、能力域正确、变更进入 PR。系统避免依赖大量细碎流程。

第二，PR 是统一入口。无论是实现、目标变更、文档更新、修复、重构，只要它推动项目前进，就进入 PR。AI 可以围绕 PR 做自动检查和归整。

第三，AI 负责 reconciliation。系统持续扫描事实痕迹，发现缺口、冲突、遗漏和异常，把需要人类判断的内容抬出来，把可以自动补偿的内容直接整理。

这使得团队可以在异步、低管理成本、低规则压力下运行。

## 六、ReconcileOps 的最终形态

ReconcileOps 不是一个传统项目管理流程，而是一套低规则协作协议。

它的三层底线是：

```txt
L1：任何工作都必须服务于 Deadline + 可验证完成定义
L2：任何变更都必须映射到它影响的 Capability Scope
L3：任何推进项目的实际变更都必须通过 PR，并挂载 Goal、Scope、Decision Owner
```

它的运行方式是：

```txt
人类自由工作
PR 承载变更
AI 审查痕迹
系统归整状态
人类裁决关键问题
```

它的目标是降低团队管理成本，同时保留项目的可控性、可追踪性和可恢复性。

**ReconcileOps 的核心信念是：团队协作的稳定性，来自最低底线足够清晰，以及混乱发生后持续归整的能力。**
