# GOAL

ReconcileOps的整套系统，必须能解决或大幅缓解以下问题。

- “先射箭后画靶”的开发习惯
- 所有事情都等 PM/上司 判断
- 团队采用敏捷却没人懂敏捷，最后变成四不像
- PM 不知道开发进度、缺文档缺 Goal、只能靠人脑汇报

## 所有技能共通验收标准

- SKILL.md必须是英文

## rco-setup

rco-setup的验收标准

- 该技能必须具有幂等性
- 执行每一步之前都会先检查当前状态是否已经满足，如满足则跳过
- SKILL.md内描述的路径正确，assets下文件能够被正确地复制到对应位置
- rco-setup/assets/examples/en下的所有example必须有对应的jp,zh版本

## rco-distill-req

rco-distill-req的验收标准

- rco-distill-req在用户没有具体说明的情况下会主动提示自己支持的各种脏输入，并提议可以访谈访谈
