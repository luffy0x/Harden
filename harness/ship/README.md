# Ship Harness

验证 `$ship` 是否能在发布/部署场景中做到：

- 先发现项目配置，再出计划
- push/deploy 前要求确认
- 多候选构建时要求选择部署 candidate
- 失败时先说明原因并尝试安全自愈
- rollback 默认指部署回滚，不是 git revert 或删除镜像

