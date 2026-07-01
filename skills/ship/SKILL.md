---
name: ship
description: "安全编排日常发布工作流：从 PR head、目标开发分支、PR 与目标分支的 merge/mixed candidate、普通分支或 tag 构建镜像；打 tag 并推送到 OCI registry；部署到 Kubernetes 或项目定义的环境；验证 rollout。用于用户要求 ship、release、构建并推送镜像、部署 PR 或分支、测试 PR 与开发分支的混合候选、promote image、或执行可重复发布/部署 SOP 的场景。不用于只跑本地测试、只问概念、纯代码开发、纯文档修改、或不涉及构建/推送/部署/验证的普通任务。"
---

# Ship

## 目标

把一次发布或部署请求整理成可审计、可回滚、可验证的执行流：

```text
discover -> plan -> confirm -> build -> tag -> push -> deploy -> verify -> report
```

优先复用项目已有脚本和已记录的基础设施约定，不要临时发明发布命令。把 registry push 和集群变更都视为外部状态变更：执行前必须明确目标，执行后必须验证结果。

## 启动协议

- 如果用户显式使用 `$ship`，直接进入本 skill 流程。
- 如果用户没有显式使用 `$ship`，但请求落在本 skill 覆盖范围内，例如构建镜像、push registry、部署 PR、部署分支、验证 rollout、执行发布 SOP，先提醒用户：“这个操作适合使用 `$ship`，是否按 Ship 流程执行？”
- 用户确认使用后，先发现项目已有配置；只要求用户补充无法从项目中可靠发现的配置项。
- 用户拒绝使用时，按普通请求处理，但仍然遵守安全边界：涉及 push、deploy、覆盖 tag、修改集群时必须明确目标并确认。
- 不要因为缺少配置就直接退出。先列出已发现配置、缺失配置和建议默认值，再请用户补齐或确认。

## 不适用场景

以下场景不要主动建议使用 `$ship`：

- 只运行本地测试、lint、typecheck、单元测试或普通验证命令。
- 只讨论发布策略、部署概念、Docker/Kubernetes 原理，不执行实际构建或部署。
- 只修改代码、文档、配置模板或 CI 文件，但用户没有要求构建、推送、部署或验证发布结果。
- 只查看日志、排查线上问题、回滚事故，且没有要求构建或发布新候选。
- 只创建 PR、review PR、写 release note、打 git tag，但不推送镜像或变更环境。

如果任务边界不清楚，先问一句是否要进入 Ship 流程，不要直接执行。

## 配置项收集

确认使用 `$ship` 后，按以下顺序收集配置：

1. 从用户请求中提取：PR、分支、tag、目标开发分支、要构建的候选、要部署的候选、目标环境。
2. 从项目中发现：build 命令、Dockerfile、image 名称、registry、namespace、deploy 方法、kubeconfig/context、workload、验证命令。
3. 从本地环境确认：Docker 是否可用、registry 是否已登录、kubeconfig 是否存在、kubectl/helm/kustomize 等工具是否可用。
4. 对仍然缺失的项目，向用户要最小必要配置。

最小必要配置通常包括：

- `refs`：要构建的 PR head、merge/mixed candidate、分支或 tag。
- `image`：镜像仓库、namespace/repo、tag 规则。
- `registry`：OCI registry 地址；凭证必须来自本地 credential store，不能让用户明文提供。
- `deploy target`：是否部署、部署到哪个环境、kubeconfig/context、namespace、workload。
- `candidate`：如果构建多个候选，明确部署哪一个。
- `verify`：rollout、pod readiness、smoke test 或项目健康检查。
- `rollback`：previous image、rollout revision 或项目回滚方式；发现不到时要说明未知。

## 项目配置约定

如果项目有稳定发布流程，优先建议维护一个可选配置文件：`.codex/ship.yaml`。没有该文件时走自动发现；有该文件时，配置优先级低于用户本次明确要求，高于推断默认值。

配置文件只记录非敏感默认值，不能包含密码、token、kube secret、云厂商密钥或一次性凭证。

推荐字段：

```yaml
version: 1
refs:
  target_branch: main
  candidate: merge-candidate
image:
  registry: registry.example.com
  namespace: team
  repository: app
  tag_template: pr-{number}-merge-{shortsha}
build:
  command: make image
deploy:
  method: helm
  environment: test
  kubeconfig: ~/.kube/test
  context: test
  namespace: default
  workload: deployment/app
verify:
  commands:
    - kubectl rollout status deployment/app -n default
rollback:
  method: rollout-undo
safety:
  require_confirm:
    - push
    - deploy
    - stable-tag
```

如果项目已经有等价配置或脚本，例如 Makefile、CI workflow、Helm values、Kustomize overlay、内部 deploy config，优先读取项目既有来源，不强行要求迁移到 `.codex/ship.yaml`。

## 操作原则

- 先用一小段说明当前假设和成功标准。
- 在读取项目文件前，先用 `pwd` 或 `git rev-parse --show-toplevel` 确认 repo root。
- 优先读取本地约定：`AGENTS.md`、`CLAUDE.md`、`.codex/*`、`.github/workflows/*`、`Makefile`、package scripts、Dockerfile、Helm/Kustomize manifests、部署脚本，以及 README 中与构建/部署相关的部分。
- 有现成的 build、tag、push、deploy、verify 命令时，优先复用。
- 不打印、不索要、不写入 registry 密码、kube token、云厂商密钥。使用本地已有 credential store 和 kubeconfig。
- 不删除镜像、不 prune builder、不删除 Kubernetes 资源、不覆盖稳定 tag，除非用户明确要求。
- push 或 deploy 前，展示解析后的 registry、image name、tag、kubeconfig/context、namespace、workload 和验证命令。
- 如果请求涉及 PR，解析 PR head、目标/基础开发分支、以及可用的 merge 或 mixed candidate；对每个用户要求的候选分别制定构建计划。
- 如果需要构造 merge/mixed candidate，优先使用平台或项目已有的 merge ref；否则使用临时 worktree 或临时分支，不能污染用户当前分支，也不能提交或推送临时候选，除非用户明确要求。
- 如果 worktree 是 dirty 状态，说明本地未提交改动是否会进入镜像。不要擅自 stash、reset 或 checkout。
- 如果必要目标无法从用户请求或项目约定中发现，停下来询问缺失值，不要猜。

## 发现清单

只收集本次发布需要的信息：

- Git 状态：repo root、当前分支、当前 commit SHA、PR number、PR head ref、目标/base 开发分支、merge candidate ref、dirty files、用户额外指定的 refs。
- 构建入口：Dockerfile 路径、镜像构建脚本、`make` targets、build args、platform、service 列表。
- Registry 默认值：项目文档、`AGENTS.md`、CI 配置、已有 image references、本地 Docker login 状态。
- 部署入口：Kubernetes manifests、Helm chart、Kustomize overlay、项目部署脚本、namespace、workload name、image 字段。
- 集群默认值：kubeconfig path、context、namespace、environment name、rollout 验证命令。
- 验证入口：`kubectl rollout status`、pod readiness、service endpoint、smoke test、日志或项目 health check。

证据优先级：

```text
用户明确要求 > 项目 AGENTS/docs > 项目 scripts/config > CI workflows > 可解释的常见默认值
```

## 计划格式

在任何外部状态变更前，输出一份紧凑计划：

```text
Refs:
- pr-head: <pr-or-branch> @ <sha>
- target-branch: <development-base> @ <sha>
- merge-candidate: <pr-head mixed with target branch> @ <sha>

Images:
- <local build target> -> <registry>/<namespace>/<repo>:<tag>

Deploy:
- method: kubectl | helm | kustomize | project script | none
- kubeconfig/context: <value>
- namespace: <value>
- workload: <kind/name>
- selected candidate: <pr-head | merge-candidate | branch | tag>

Verify:
- <commands/checks>

Rollback:
- <previous image or undo path, if discoverable>
```

以下情况必须先确认再执行：

- 要 push 到远端 registry。
- 要修改集群或共享环境。
- 要覆盖 `latest`、`prod`、`main`、release line 等稳定 tag。
- deploy target、namespace 或 workload 是推断出来的，不是明确记录的。
- 构建会包含 dirty worktree 改动。
- 同时构建了多个候选，但用户没有明确要部署哪一个。

纯本地 dry run 不需要确认。

## 确认矩阵

按风险级别决定确认强度：

| 操作 | 默认行为 | 确认要求 |
|---|---|---|
| 只读 discovery、plan、verify | 可直接执行 | 不需要确认 |
| 本地 build | 可直接执行 | dirty worktree 会进入镜像时需要确认 |
| 本地 tag 非稳定 tag | 可直接执行 | 说明 tag 来源 |
| push 非稳定 tag | 先计划后执行 | 需要确认 registry、repo、tag |
| deploy 到个人/临时环境 | 先计划后执行 | 需要确认环境、namespace、workload、candidate |
| deploy 到共享测试环境 | 先计划后执行 | 需要确认 kube context、namespace、workload、candidate、rollback |
| 覆盖稳定 tag | 默认拒绝 | 用户明确要求后仍需二次确认 |
| deploy 到 staging/prod | 默认只出计划 | 用户明确要求后仍需二次确认，并列出 rollback |
| 删除镜像、清理资源、prune builder | 默认拒绝 | 只有用户明确要求才执行 |
| rollback | 默认只给命令 | 只有用户明确授权 auto-rollback 或本次确认后才执行 |

二次确认必须包含将要改变的外部状态，例如 image tag、registry、cluster context、namespace、workload、当前候选和回滚路径。

## Tag 规则

默认使用可追踪、非破坏性的 tag：

- PR head：`pr-<number>-head-<shortsha>`。
- Merge/mixed candidate：`pr-<number>-merge-<shortsha>`。
- 分支构建：`<sanitized-branch>-<shortsha>`。
- 额外 ref：`<sanitized-ref>-<shortsha>`。
- 不覆盖 `latest`、release-line 或生产 tag，除非用户明确要求。
- 如果项目已有 tag 格式，优先遵循项目格式，并说明来源。

## 执行模式

根据用户请求选择最小执行模式；不确定时先用 `plan-only`。

- `plan-only`：只发现信息并输出计划，不构建、不 push、不部署。
- `dry-run`：执行只读检查和本地可逆检查，展示将要执行的命令，不改变 registry 或集群。
- `build-only`：只构建本地镜像，不 push、不部署。
- `push-only`：只 tag/push 已存在或刚构建的镜像，不部署。
- `deploy-only`：只部署已存在的镜像，不重新构建。
- `verify-only`：只验证当前环境状态，不改变镜像或集群配置。
- `rollback-only`：只准备或执行用户确认过的 rollback。
- `full`：完整执行 build、tag、push、deploy、verify。

模式规则：

- 用户明确指定模式时遵循用户选择。
- 用户说“看一下怎么发”“给我发布计划”时使用 `plan-only`。
- 用户说“试跑”“dry run”时使用 `dry-run`。
- 用户说“打镜像”但没有说 push/deploy 时使用 `build-only`。
- 用户说“部署这个镜像”时使用 `deploy-only`，除非镜像不存在且用户确认需要构建。
- 用户说“发一下”“ship 一下”且配置齐备时可以进入 `full`，但 push/deploy 前仍按确认矩阵执行。

## 执行流程

1. 确认是否使用 `$ship`，并收集/补齐必要配置。
2. 检查 repo，收集发现清单。
3. 解析 refs。PR 工作流中，先确认 PR head、目标开发分支、merge/mixed candidate；额外 ref 也必须先验证存在。
4. 选择构建 adapter：
   - 优先项目脚本或 `make` target
   - 其次直接使用 Docker/BuildKit
   - 只有本地命令缺失时，才复现 CI workflow 中的构建逻辑
5. 构建每个用户要求的候选，并记录 image ID 或 digest。
6. 按计划给镜像打 tag。
7. 只有 push 目标被确认或明确记录时，才 push 镜像。
8. 如果构建了多个候选，只部署用户指定的候选；没有指定时先确认。
9. 用项目原生部署方式部署。
10. 验证 rollout 和健康状态。
11. 报告实际变更、正在运行的镜像和验证结果。

## Adapter 选择

选择能贴合项目的最窄 adapter：

- Docker：使用已有 Dockerfile 和 build args；只有项目已使用或确实需要多平台输出时，才优先 `docker buildx`。
- Registry：任何 OCI registry 都可以。Aliyun、GHCR、ECR、GCR、Docker Hub 都只是 provider 细节，不是不同工作流。
- Kubernetes：优先 Helm/Kustomize/项目脚本。只有项目本来就这么做，或用户明确要求时，才直接 `kubectl set image`。
- 验证：优先项目 smoke test；其次 rollout status、pod readiness、recent logs、service health check。

## 失败处理

某一步失败时：

- 先反馈失败原因：说明失败边界、失败命令、关键错误摘要、最后一个成功状态、已产生的外部状态变化。
- 优先自行处理可安全恢复的问题，再要求用户补充信息。自愈必须是非破坏性的、可解释的、不会覆盖稳定 tag、不会删除资源、不会修改用户未确认的外部状态。
- build 或 push 失败后不要继续 deploy；deploy 失败或 verify 失败后不要继续 promote。
- 如果 deploy 已改变集群但验证失败，尽量识别 previous image 或 rollout revision，并给出 rollback 命令。
- 不自动 rollback，除非用户本次明确要求 auto-rollback。

按以下顺序处理失败：

1. 分类：判断是配置缺失、ref 不存在、工作区状态问题、构建失败、registry 登录/权限失败、网络/临时依赖失败、部署目标不明确、集群权限失败、rollout/健康检查失败，还是未知失败。
2. 自行修复：对安全项直接尝试，例如重新读取配置、刷新 refs、重新解析 PR 信息、选择项目已有脚本、修正本地 tag 格式、等待后重试一次临时网络/rollout 检查、补充只读诊断命令。
3. 降级方案：如果主 adapter 不可用，尝试项目内已有替代路径，例如从 `make image` 降级到项目记录的 `docker build`，从项目 smoke test 降级到 `kubectl rollout status` 和 pod readiness。
4. 停止并请求用户输入：只有无法安全推断或继续会改变外部状态时，才要求用户补充配置或确认操作。

可以要求用户兜底提供或确认的内容：

- 缺失配置：registry 地址、image namespace/repo、目标环境、kubeconfig/context、namespace、workload、deploy 方法、验证命令。
- 候选选择：构建了多个候选时，指定部署 `pr-head`、`merge-candidate`、branch 或 tag。
- 权限状态：让用户确认已经完成 `docker login`、云厂商登录、VPN/网络连接、kubeconfig 权限配置；不要让用户粘贴密码或 token。
- 风险确认：是否允许覆盖稳定 tag、是否允许修改共享环境、是否允许回滚、是否允许重试 push/deploy。
- 项目事实：如果项目没有记录构建/部署入口，请用户提供项目标准命令或指向相关文档。
- 外部故障：当 registry、集群、网络或第三方服务不可用时，让用户确认等待、换目标环境、或稍后重试。

失败回复格式：

```text
失败边界: <discover | plan | build | push | deploy | verify>
原因判断: <简短分类和证据>
已完成: <最后成功状态>
已尝试自愈: <做过的安全恢复动作>
当前风险: <是否已有外部状态变更>
需要你确认/补充: <最小必要项，若没有则写 none>
下一步建议: <retry | change config | rollback | stop>
```

## 输出要求

工作中简短更新当前边界：discovery、plan、build、push、deploy、verify。

最终回复必须包含：

- 构建过的 refs
- push 过的 images、tags 或 digests
- 变更过的 deploy target
- 验证结果
- rollback 说明
- 有意跳过的步骤
