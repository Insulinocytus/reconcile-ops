# FAQ

## 1. ReconcileOps 能解决“先射箭后画靶”的开发习惯吗？

能解决，而且这是 ReconcileOps 的强项。

传统流程通常要求团队先创建 issue 或 ticket，再写代码，最后创建 PR。现实中，这个顺序经常被打破：开发者可能先发现问题、先写出实现、先开 PR，然后才回头补上下文。

ReconcileOps 不把这种行为本身视为失败。它接受“先写代码”会发生，但要求 PR 成为最小 Trace Anchor。也就是说，PR 合并前必须补齐三个问题：

```txt
它推进哪个 Goal？
它影响哪些 Capability Scope？
它需要谁来裁决？
```

因此，没有 ticket 的 PR 不一定非法；真正高风险的是找不到对应 Goal、Scope 或 Decision Owner 的 PR。AI 可以在 PR 阶段识别 orphan PR，要求作者补齐 Goal，或者把它归类为 Goal Change PR / Mixed PR。

ReconcileOps 的重点不是强迫所有人按理想顺序工作，而是确保混乱不会长期隐形存在。

## 2. ReconcileOps 能解决 PM 什么都管、上游堵住下游的问题吗？

只能部分解决。

ReconcileOps 可以缓解“所有事情都等 PM 判断”的问题，因为它把责任从职位和汇报线转向 Capability Scope。数据库变更应该找 Database Owner，AWS 变更应该找 AWS Owner，发布风险应该找 Release Owner，产品目标变化才需要 Goal Decision Owner 或 Product Owner 裁决。

这样可以减少不必要的 PM 中转，让真实具备判断能力的人进入 review、approve、block、escalate 路径。

但 ReconcileOps 不能自动创造组织授权。如果公司仍然规定所有目标、范围、优先级、发布和验收都必须由 PM 点头，那么 AI 最多只能暴露瓶颈：

```txt
哪些 PR 卡在 PM review
哪些 Goal 缺少 Decision Owner
哪些 Scope 本应由技术 owner 裁决
哪些 blocker 已经超过合理等待时间
哪些任务不是技术 pending，而是决策 pending
```

所以，ReconcileOps 能解决“PM 瓶颈不可见”和“错误路由”的问题，但不能单独解决“PM 被组织设计成唯一闸门”的问题。要真正解决这个问题，团队还需要明确 Owner Matrix 或 Delegation Rule。

## 3. ReconcileOps 能解决团队采用敏捷却没人懂敏捷，最后变成四不像的问题吗？

能解决，但方式不是教团队背 Scrum。

这个问题的本质不是团队少了某个敏捷仪式，而是没人知道哪些规则真的必须遵守，哪些只是形式。团队可能有 sprint、daily standup、ticket、看板和 review，但这些东西之间没有清晰关系，最后既不像 waterfall，也不像 Scrum。

ReconcileOps 绕开“敏捷名词崇拜”，只保留三条真正必须遵守的协作底线：

```txt
L1：任何工作都必须服务于 Deadline + 可验证完成定义
L2：任何变更都必须映射到它影响的 Capability Scope
L3：任何推进项目的实际变更都必须通过 PR，并挂载 Goal、Scope、Decision Owner
```

这意味着团队可以继续使用 sprint、daily standup、retro 或 story point，但这些只是辅助工具，不是系统稳定性的来源。真正必须执行的是 Goal、Scope 和 PR Trace Anchor。

因此，ReconcileOps 可以让团队明确地说：我们不是在执行一个半吊子的 Scrum，而是在执行一套低规则协作协议。敏捷仪式可以保留，但不能替代 ReconcileOps 的三条底线。

## 4. ReconcileOps 能解决 PM 不知道开发进度、缺文档缺 Goal、只能靠人脑汇报的问题吗？

能解决大部分，但不应该承诺生成绝对准确的百分比进度。

ReconcileOps 要求 Goal 具备可验证完成定义：

```txt
Deadline
Deliverable
Acceptance Criteria
Verification Method
```

PR 必须挂载 Goal，GitHub Project / Label / Check 承载轻量状态，AI 负责 Project Status Sync、Nightly Inspect、Doc Debt Detection 和 Orphan PR Detection。

这样，PM 不需要完全依赖开发者主动汇报，也不需要依赖 team leader 的大脑记忆。状态可以从实际协作痕迹中归整出来：

```txt
Goal A
- Acceptance Criteria 1: Done, evidence = PR #12 + test pass
- Acceptance Criteria 2: In review, evidence = PR #15
- Acceptance Criteria 3: Blocked, reason = awaiting Product decision
- Unknown / drift: PR #18 modifies scope but no Goal update
```

这比“我感觉完成了 80%”可靠得多。

如果团队一定需要百分比，也应该从验收标准层面派生，而不是从主观感觉派生。例如 5 个 acceptance criteria 中，3 个 verified，1 个 in review，1 个 blocked，可以表达为：

```txt
Verified: 60%
In review: 20%
Blocked: 20%
```

ReconcileOps 的目标不是制造漂亮但虚假的进度数字，而是生成 evidence-based status。百分比可以作为派生指标，但不能替代事实本身。
