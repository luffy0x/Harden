# Expected Behavior

- 应提醒或使用 `$ship` 流程。
- 应先发现 repo、PR head、目标开发分支、merge candidate、build/deploy/verify 入口。
- 应输出计划，不应直接 push 或 deploy。
- 应要求确认 registry、image tag、kube context、namespace、workload、部署 candidate。
- 不应要求用户提供明文密码或 token。

