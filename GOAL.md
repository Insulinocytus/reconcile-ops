# GOAL

ReconcileOps的整套系统，必须能解决或大幅缓解以下问题。

- 没有ticket/issue就直接开工产出PR的“先射箭后画靶”的开发习惯
- 所有事情都等 PM/上司 判断
- 团队采用敏捷却没人懂敏捷，最后变成四不像
- PM 不知道开发进度、缺文档缺 Goal、只能靠人脑汇报

## 所有技能共通验收标准

- SKILL.md必须是英文

## rco-setup

rco-setup的验收标准

- 技能执行后会先立马阅读RULE.md
- 技能必须具有幂等性：重新执行时所有已满足的步骤必须跳过，不可重复执行
- 若.reconcile-ops/不存在，从skills/rco-setup/assets/.reconcile-ops/复制；若已存在则不可覆盖
- 必须逐个检查各类工具是否已安装，仅安装缺失的工具，不可跳过检查直接安装
- mise必须在~/.zshrc中包含精确行eval "$(mise activate zsh)"，不可追加重复行
- 必须向用户询问preferred_language（en/zh/jp），若用户未指定则不可默认
- 选定语言的目录必须存在于.reconcile-ops/examples/下，若不存在则停止并报告
- .reconcile-ops/examples/下的顶层*.md必须是指向选定语言目录的相对符号链接，不可是普通文件
- 不可创建或覆盖.reconcile-ops/examples/en、zh、jp下的语言特定文件
- rco-setup/assets/examples/en下的所有md文件必须有对应的jp,zh版本

## rco-distill-req

rco-distill-req的验收标准

- 技能执行后会先立马阅读RULE.md，如未找到则必须提醒用户执行rco-setup命令
- 技能会阅读.reconcile-ops/examples/requirement.md作为结构参考
- 在用户调用技能时若没有提供输入，会主动提示自己支持的各种输入格式（会议记录、STT转录、Notion、Slack、邮件等），并提议可以访谈式对话
- 技能会输出.reconcile-ops/examples/requirement.md同等结构的requirement文档，路径为`docs/requirements/<business-topic>.md`
- 不可提交原始客户输入（transcript、Slack dump、邮件原文、STT文本）
- 未确认的疑问不可写入Git文件，只能在最终响应中报告为PM跟进项
- 访谈模式下每次只问一个聚焦问题，直到有足够稳定内容才写文档
- 输入过模糊无法产出稳定requirement时必须停止，不可凭空编造事实
- 文件命名必须基于business topic，不可基于会议日期
- 技能完成后必须询问用户是否继续执行rco-define-goal或先执行rco-create-pr

## rco-define-goal

rco-define-goal的验收标准

- 技能执行后会先立马阅读RULE.md，如未找到则必须提醒用户执行rco-setup命令
- 技能会阅读.reconcile-ops/examples/goal.md作为结构参考
- Goal ID必须从docs/goals、GOAL_ISSUE_MAP.json和Git历史中发现的ID取最大值+1，绝不可复用已存在的ID
- 当requirement内容不足以产出可验证的Goal时，必须停止并报告缺失确认项，不可创建推测性Goal
- Source Requirements必须使用Markdown相对链接，不可使用纯文本路径
- 技能完成后必须提醒用户执行rco-create-pr

## rco-create-spec

rco-create-spec的验收标准

- 技能执行后会先立马阅读RULE.md，如未找到则必须提醒用户执行rco-setup命令
- 技能会阅读.reconcile-ops/examples/spec.md作为结构参考
- 技能会读取来源requirement或Goal文件，并通过链接追踪到关联文件以充分grounding设计
- 输出路径必须为docs/specs/<business-area>/<capability-or-flow>.md格式
- Source Documents必须使用Markdown相对链接指向来源requirement和Goal
- spec不可是task checklist，必须是baseline design document
- 技能完成后必须提醒用户执行rco-create-pr

## rco-create-issue

rco-create-issue的验收标准

- 技能执行后会先立马阅读RULE.md，如未找到则必须提醒用户执行rco-setup命令
- 技能会阅读.reconcile-ops/examples/goal-issue.md作为结构参考
- 创建issue前必须先检查是否已存在同Goal ID的issue，若已存在则跳过且不修改
- Issue标题格式必须为[G-000001] Goal Title
- Issue body只包含default-branch的Goal文件链接，不可复制Goal详情
- GOAL_ISSUE_MAP.json存储goal id -> issue id映射
- v1版本不可更新已有issue内容、关闭issue或同步Project status
- 不可对同一Goal ID创建重复issue

## rco-create-pr

rco-create-pr的验收标准

- 技能执行后会先立马阅读RULE.md，如未找到则必须提醒用户执行rco-setup命令
- 技能会阅读.reconcile-ops/examples/pr.md作为结构参考
- 技能必须先通过git status --short检查变更文件
- PR描述必须基于实际变更文件生成
- Review Notes中当docs/requirements/**变更时需确认requirement反映稳定client intent；当docs/goals/**变更时需确认Goal可验证
