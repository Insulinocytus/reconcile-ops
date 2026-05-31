# ReconcileOps：一套低规则、AI 归整的团队协作方法

团队协作的核心问题，通常被包装成流程问题、管理问题、文档问题、进度问题。很多方法会尝试设计更完整的流程、更细的角色、更严格的文档模板、更复杂的看板字段。但现实中的团队很少像流程图那样运转。

人会临时改主意，会先写代码再补说明，会跳过看板，会在 Slack 里做决定，会忘记更新文档，会因为紧急问题绕过原有路径。AI Agent 也一样，它可能漏读上下文、过度执行、提前收工、误判任务边界。一个团队系统如果依赖所有参与者持续、正确、完整地遵守规则，它天然脆弱。

**ReconcileOps 的出发点是：不要假设人类会持续正确地维护流程，而是让真实工作留下足够痕迹，再由 AI 持续审查、归类、补偿和校正。**

它追求的目标是：

> 人类围绕少数协作底线自由工作，AI 持续把真实工作中的混乱归整为可追踪、可验证、可推进的状态。

ReconcileOps 不是要消灭混乱。它接受混乱会发生，也接受第一次提交经常不完整。它真正反对的是混乱长期隐形存在。

> 可以容忍混乱输入，不能容忍隐形漂移。

## 一、团队协作的最低底线

ReconcileOps 先定义团队协作中真正需要坚守的底线。这里的“低规则”不是说没有判断成本，而是说系统只保留最少但必须保留的协作底线，不再要求团队长期维护大量中间状态。

这套底线分为三层。

## L1：Deadline + 可验证完成定义

团队协作的最底层目标是：

> 在给定期限内，交付一个可被验证为完成的结果。

这里的 Goal 必须被写成可验证的完成定义。一个有效目标至少包含：

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

团队里最危险的目标，是只有方向感、缺少完成定义的目标。比如“优化系统”“改善文档”“完成基础设施建设”都太松散。这些说法能说明方向，但不能判断什么时候完成。它们可以作为意图，但进入执行前必须尽量变成可验证结果。

这里的“尽量”很重要。ReconcileOps 不假设每个 Goal 在第一次被写下时就足够好。PM 可以在写 Goal 时主动使用 AI skill 做自我审查；PR 创建后可以由 AI review 和人类 reviewer 继续检查；合并后也可以由定时 AI inspect 发现缺口并创建补偿 issue。

ReconcileOps 中的第一条底线是：

> 任何有效工作都必须服务于一个有期限、可验证的完成定义；如果定义不完整，系统应该尽快发现并推动补齐。

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

Scope 和 reviewer 不应该只依赖 AI 临场判断。项目内的硬性规定应该落地为 repo 中的 agent skill、agent prompt、配置文件或其他可审查的项目文件。例如，某些目录变更必须加入某类 reviewer，某些 Goal 文件变更必须加入 Goal Decision Owner，某些 workflow 变更必须加入 Release Owner。

AI 的职责不是替团队发明责任结构，而是读取这些项目内规定，结合 PR diff 和元数据做归整。如果规定覆盖不了某个变更，AI 应该提出警告，让人类确认或补充规则。

这层的底线是：

> 任何影响特定能力域的变更，都必须让对应能力域的人拥有审查权；这些审查规则应该尽可能在项目内显式沉淀，而不是靠临场记忆。

如果一个 PR 修改了 Goal、验收标准、期限或范围，它还需要加入拥有 Goal 决定权的人 review。实现层面的裁决归 Capability Owner，目标层面的裁决归 Goal Decision Owner。

## L3：PR as Trace Anchor

ReconcileOps 把 PR 定义为唯一闸门，也是最小 Trace Anchor。PR 是实际变更最终都要经过的审查入口，也是系统追踪工作的最小单位。

任何能推动项目向 Goal 前进的 PR 都是有效 PR。任何找不到对应 Goal 的 PR 都是高风险信号。它说明有人正在做脱离目标的工作，或者现有 Goal 无法覆盖真实需求。这两种情况都需要被显式暴露并审查。

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

Mixed PR 本身不是问题。真正重要的是 review 规则必须清楚：当 PR 修改实现时，它需要相关 Capability Scope 的 review；当 PR 修改 Goal 时，它需要 Goal Decision Owner 的 review；当 PR 同时修改 Goal 和实现时，它必须同时满足这两类 review 要求。

这些规则应该被写进项目内的文档、agent skill、agent prompt、配置文件或 GitHub Actions 检查中。只要规则能被执行，Mixed PR 就不需要被禁止。

L3 的底线是：

> 任何推进项目的实际变更都必须通过 PR，并在 PR 中挂载 Goal、Scope、Decision Owner。

## 二、ReconcileOps 的核心思想

ReconcileOps 的核心可以压缩成一句话：

> Minimal rules for humans. Continuous reconciliation by AI.

人类只需要围绕三件事工作：

```txt
写清楚目标
找对能力域
通过 PR 留痕
```

但 ReconcileOps 不要求人类一次性把所有事情做对。它更像一个多层补偿系统。

```txt
提交前辅助（Pre-PR Assist）：人在提交前主动用 AI skill 自查
PR 闸门审查（PR Gate Review）：PR 创建后由人类 reviewer 和 AI review 检查
合并后巡检（Post-merge Inspect）：定时 AI inspect 发现缺口并创建补偿任务
```

剩下的工作由 AI 辅助完成：

```txt
检查 PR 是否关联 Goal
检查 Goal 是否具备可验证完成定义
根据项目内规则识别 PR 影响的 Capability Scope
判断 reviewer 是否覆盖必要能力域
发现 orphan PR
发现文档债
发现目标变更
发现实现与验收标准的偏差
生成补偿任务
更新状态视图
提醒需要人类裁决的问题
```

这套系统承认真实团队会混乱。它的重点不是让混乱永远不发生，而是让混乱可以被捕获、被归类、被修复。

## 三、Git 管当前成果，GitHub 管状态，AI 管归整

Git 很适合管理当前有效的长期成果物和协作协议，比如：

```txt
Goal
spec
architecture docs
skills
agent prompts
project config
code
workflow config
```

这里强调“当前有效”。ReconcileOps 更关注当前系统应该如何工作，而不是完整记录每一次变化的来龙去脉。历史可以通过 Git history、PR、CHANGELOG 或团队自选机制保留，但日常协作入口应该是当前有效状态。

状态变化频率很高，比如任务是否 blocked、谁正在处理、当前 review 是否完成、文档是否欠债。把这些状态全部放进 Git，会制造大量低价值 PR。

ReconcileOps 的分工是：

```txt
Git：管理当前有效的长期成果物和协作协议
PR：承载实际变更和 Trace Anchor
GitHub Project / Label / Check：承载轻量状态
AI：持续审查、归类、补偿、校正
```

PR 是闸门。Project board 是状态视图。Docs 是当前成果。AI Agent 是 reconciliation 层。

ReconcileOps 不强制 ADR。架构设计相关文档属于长期成果物，应该由 Git 管理；至于具体文件位置、命名和组织方式，由每个 repo 自己决定，不由这份方法论统一规定。

## 四、AI Skill 的正确位置

在设计初期，一个常见倾向是做一个巨大的 AI Skill 包，把开发团队和管理团队的所有日常工作全部打包进去。但人的行为太灵活，所有日常动作都很难被提前预测。

ReconcileOps 中，Skill 的职责从“规定人怎么工作”转为“整理人已经做过的事”，同时在关键节点提供自我审查和自动检查。

AI Skill 更适合承担这些稳定任务：

```txt
Goal Self Review
PR Reconciliation
Goal Validation
Scope Detection
Reviewer Routing
Doc Debt Detection
Orphan PR Detection
Release Readiness Check
Project Status Sync
Nightly Inspect
```

这类 Skill 的共同点是：输入来自已有事实，输出用于修复协作状态。它们不会要求人完全按流水线行动。它们负责在事前提醒、PR 阶段检查、事后巡检中，把真实行动归整回系统可以理解的结构。

AI 的归整能力需要依据。项目内的硬性规则应尽量沉淀为可读的 skill、prompt、配置文件或 workflow 检查。AI 读取这些规则，再结合 PR diff、issue、labels、project 状态做判断。AI 可以提出警告、补偿任务和修复建议。但组织冲突和业务裁决仍然归人类。

## 五、PR 前可以混乱，但结论要回写

大量真实决策发生在 PR 之前。它们可能来自 Slack、会议、实验分支、临时讨论、放弃的尝试。ReconcileOps 不试图完整治理这些过程。

它只要求一件事：

> 任何影响 Goal、验收标准、架构、风险或责任分配的结论，在进入交付路径时，必须回写到 PR、Goal、项目文档或其他 Trace Anchor 中。

这不是要求每一行代码都能追溯到会议录音，也不是要求所有脏数据都被绑定进系统。ReconcileOps 不追求完整因果链，只追求关键结论的可恢复上下文。

如果 AI 发现一个 PR 包含重大结论，但缺少来源，它可以请求作者补充 Slack thread、会议纪要、实验分支、issue discussion 或一句简短说明。这类来源追踪默认只要求尽力而为，不应该变成无穷无尽的硬性负担。

## 六、冲突由人解决，结果回到系统

ReconcileOps 不负责消灭组织冲突，也不负责定义所有冲突的最终裁决规则。

Goal Decision Owner、Capability Owner、Release Owner 之间发生冲突，本身就是一种混乱。ReconcileOps 不应该试图用更多流程把它完全消除。相关人可以开会、私聊、同步讨论，用他们认为合适的方式解决。

ReconcileOps 只要求解决结果回到系统里：

```txt
PR comment
Goal update
project document update
GitHub Project note
configuration update
```

没有回写结果前，AI 不应该把冲突视为已解决。它可以继续标记为阻塞、需要人类裁决，或创建补偿任务。

这也是 ReconcileOps 和传统治理方案的区别：它不替团队设计权力结构，只要求关键冲突不要长期隐形。

## 七、适用边界

ReconcileOps 第一版以单项目为边界运行。

为了降低实现复杂度，这里的项目暂时定义为：

```txt
1 Project = 1 Repo = 1 GitHub Project
```

它不太关注团队人数。真正重要的是协作事实是否能被一个 repo、一个 GitHub Project 和一组 PR 捕获。

第一版暂时不试图解决：

```txt
多 repo Goal 同步
跨项目资源竞争
组织级 Owner 政治
公司级治理流程
```

如果未来要支持多 repo 或更大的组织边界，应该先让单 repo 内的 Goal、Scope、PR Trace Anchor、AI inspect 跑稳定，再讨论上层聚合。

## 八、为什么这套方法更抗混乱

ReconcileOps 的鲁棒性——也就是系统在混乱中继续运转的能力——来自三个设计选择。

第一，规则足够少。人类只需要围绕目标、能力域和 PR 留痕工作。系统避免依赖大量细碎流程。

第二，PR 是统一入口。无论是实现、目标变更、文档更新、修复、重构，只要它推动项目前进，就进入 PR。AI 可以围绕 PR 做自动检查和归整。

第三，AI 负责 reconciliation。系统持续扫描事实痕迹，发现缺口、冲突、遗漏和异常，把需要人类判断的内容显式呈现出来，把可以自动补偿的内容直接整理。

这使得团队可以在异步、低管理成本、低规则压力下运行。它不保证人类不会制造混乱，只降低混乱长期不可见、不可追踪、不可修复的概率。

ReconcileOps 目前仍然是一个实验性协作协议。它不是经过大规模组织验证的成熟流程，也不试图在这个阶段证明自己优于所有协作模型。

它提出的是一个待实践检验的方向：在允许混乱输入的团队系统里，少数 Trace Anchor 加持续 AI 归整，可能比依赖复杂流程的持续正确执行更鲁棒。

## 九、ReconcileOps 的最终形态

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
裁决结果回到 Trace Anchor
```

核心信念：

> 团队协作的稳定性，不来自所有人持续正确地遵守复杂流程，而来自最低底线足够清晰，以及混乱发生后持续归整的能力。

它的目标是降低团队管理成本，同时保留项目的可控性、可追踪性和可恢复性。
