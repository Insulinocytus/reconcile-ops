# ReconcileOps（RCO）快速上手

ReconcileOps（RCO）是一套低规则、AI 持续归整的协作方法。人类围绕三条底线自由工作，AI 在提交前、PR 闸门、合并后巡检三个时机持续对齐，让混乱不会积累为隐形漂移。

核心原则：**Minimal rules for humans. Continuous reconciliation by AI.**

## 5 分钟上手

```bash
# 1. 初始化
rco-setup                  # 初始化 .rco/、安装工具链、配置 GitHub Actions

# 2. 整理需求
rco-distill-req            # 会议纪要/访谈 → 结构化需求
rco-define-goal             # 需求 → Goal（验收标准）

# 3. 提交变更
rco-create-pr              # 创建 PR + 自动匹配 reviewer

# 4. 审查 & 合并
rco-review-pr              # 六轴审查 → 通过后合并

# 夜巡自动运行
rco-nightly-inspect        # 检测漂移 → 创建巡检 Issue
```

---

## 产物与流向

```
原始输入 → [rco-distill-req] → 需求文档
  ↓
[rco-define-goal] → Goal 文件 (docs/goals/G-XXXXXX.md)
  ↓
[rco-create-goal-issue] → GitHub Issue
  ↓
实现代码 + 测试
  ↓
[rco-create-pr] → PR（自动匹配 reviewer）
  ↓
[rco-review-pr] → 六轴审查 → 合并
  ↓
[rco-nightly-inspect] → 夜巡 & drift 报告

代码质量和开发效率审查（按需运行或包含在夜巡中）：

[rco-review-spaghetti] → 10 维度代码质量扫描
[rco-review-toil] → 检测可自动化的重复劳动
```

架构变更时，在 PR 之前插入：

```
[rco-create-adr-issue] → 讨论 & 关闭 ADR Issue → 代码实现 → [rco-create-pr]
```

---

## 各阶段产物

### 需求文档（`docs/requirements/*.md`）

`rco-distill-req` 将会议纪要、访谈录音、邮件等原始输入整理为结构化需求，按业务主题组织：

```markdown
# Requirements: 订单确认

## Situations

### 客户下单后未收到确认邮件
用户完成支付后 2 分钟才收到确认，焦虑地重复下单。

## User Confirmed Needs
- 确认邮件 5 秒内发出
- 邮件包含订单号和预计送达时间

## User Confirmed Doesn't Need
- 短信通知（本期不做）

## Pending Confirmation
- 是否需要其他通知？用户未明确
```

**关键约束**：只记录用户亲口确认的内容，推论和假设放 Pending Confirmation。

### Goal 文件（`docs/goals/G-XXXXXX.md`）

Goal 文件只写验收标准，不写状态、负责人、截止日期——这些全部在 GitHub Issue / Project 中维护。

```markdown
# G-000001: 确认邮件 5 秒内发出

## Source Requirements

- [Login System](../requirements/login-system.md)

## Acceptance Criteria

- 确认邮件在下单后 5 秒内发出
- 邮件包含订单号和预计送达时间
- 24h 内 99% 的邮件 5 秒内送达
```

### GitHub Issue

`rco-create-goal-issue` 为每个 Goal 创建 Issue。标题格式 `[G-000001]`。Issue 是**唯一的状态容器**：里程碑、负责人、状态、验收进度都在这里，Goal 文件本身不携带状态。

Issue 会把 Goal 文件里的 Acceptance Criteria 镜像成 checklist：

```markdown
Goal: https://github.com/OWNER/REPO/blob/main/docs/goals/G-000001.md

## Acceptance Criteria

- [ ] 确认邮件在下单后 5 秒内发出
- [ ] 邮件包含订单号和预计送达时间
- [ ] 24h 内 99% 的邮件 5 秒内送达

PRs:
```

实现 PR 合并后，由人根据实际验收结果手动勾选对应 checklist。Acceptance Criteria checklist 是 Goal 进度的计算口径：总项数是分母，已勾选项是分子。

### PR

`rco-create-pr` 创建 PR 并根据 `.rco/config.json` 的 `pr_reviewers` 自动匹配 reviewer。实现类 PR 的 body 必须引用 Goal Issue（`#42`），否则标记为孤儿 PR。PR 合并后，维护者回到 Goal Issue 手动勾选已满足的 Acceptance Criteria。

### ADR

影响全局架构的变更必须先开 ADR Issue（`rco-create-adr-issue`），关闭后 `rco-create-adr-md` 聚合到 `docs/adr.md`。

---

## Skills 速查

| Skill | 何时用 | 作用 |
|-------|--------|------|
| **rco-setup** | 项目初始化 | 初始化 `.rco/`、安装工具链、配置 GitHub Project + Actions |
| **rco-sync-project** | Project AC Progress 过期时 | 同步 Goal Issue AC 进度到 Project |
| **rco-distill-req** | 收到原始输入（会议纪要、访谈录音等） | 整理为结构化需求文档 |
| **rco-define-goal** | 需求稳定后 | 产出 Goal 文件（验收标准 + 来源引用） |
| **rco-create-goal-issue** | Goal 文件合入主分支后 | 为 Goal 创建带 AC checklist 的 Issue |
| **rco-create-issue** | 创建非 Goal / 非 ADR 的通用 Issue | Why / TODO / References 三段式 |
| **rco-create-pr** | 变更准备提交 | 创建 PR、匹配 reviewer、关联 Goal |
| **rco-review-pr** | PR 需审查时 | 六轴 + 自定义维度审查 |
| **rco-create-adr-issue** | 需要记录/推翻架构决策 | 创建 ADR Issue（`adr` 标签） |
| **rco-create-adr-md** | 闭合 ADR Issue 积累后 | 汇总已关闭 ADR 到 `docs/adr.md` |
| **rco-review-spaghetti** | 代码质量审查 | 10 维度代码质量扫描 |
| **rco-review-toil** | 团队被手动流程拖累时 | 检测 toil（可自动化的重复劳动） |
| **rco-nightly-inspect** | 夜间/定期巡检 | 检查 Goal↔Issue/AC checklist 对齐、孤儿 PR、ADR 同步 |
| **rco-lets-go** | 不确定用哪个 skill | 路由到合适的 RCO skill |

---

## 规则

### 硬性规则

1. **实现类 PR 必须引用 Goal Issue**（body 中 `#123`），否则标记为孤儿 PR。
1. **所有 PR 必须通过 `rco-review-pr` 的 6+ 轴审查才可合并。**
1. **实现 PR 合并后，必须人工勾选 Goal Issue 中已满足的 Acceptance Criteria。**
1. Goal 文件只写验收标准，不写状态、负责人、截止日期——这些由 Issue / Project 承载。
1. Goal ID 严格递增、不复用。不再活跃的 Goal 加 `> **Superseded**`，不删文件。
1. 架构变更必须先开 ADR Issue，关闭后聚合到 `docs/adr.md`。 

### 人工协作

| 场景 | 人需要做什么 | 为什么 |
|------|------------|----------|
| 需求澄清 | 确认 Pending Confirmation 项 | 否则需求文档无法定稿 |
| Goal 进度 | PR 合并后勾选已满足的 Acceptance Criteria | checklist 是 PM 查看进度的入口 |
| ADR 决策 | 在 Issue 中做最终决策并关闭 | 架构变更必须走 ADR |
| Code Review | 响应 Required / Critical Findings | PR 须通过六轴审查才可合并 |
| 夜巡结果 | 审阅巡检 Issue | 巡检结果 Issue 必须每日人工检查（决定处理或不处理） |

### 夜巡

`rco-nightly-inspect` 自动检查 Goal↔Issue 对齐、Goal file 与 Issue checklist 的 Acceptance Criteria 漂移、孤儿 PR、ADR 同步。发现漂移时创建巡检 Issue，**3 个工作日内须响应**；夜巡只报告 drift，不直接修改已有 Issue。
