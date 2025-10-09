# 提交状态模块说明

该目录抽象作业的状态机与状态同步逻辑，确保列表与详情页展示一致。

## 关键文件
- `submission_models.dart`
  - 定义 `SubmissionStage` 枚举，覆盖 `queued → ocr → parsed → graded → reported` 全流程，并提供 `badgeColor`/`label` 方法生成 UI 标签。
  - `Submission` 数据类记录任务基础信息、页列表与实时进度，用于渲染列表及详情。
- `submission_controller.dart`
  - `SubmissionController` 通过 API 客户端加载初始列表，并监听 `RealtimeClient` 推送的状态更新。
  - `_syncFromRealtime` 根据收到的事件更新指定任务的阶段与百分比，当实时连接断开时会 fallback 到 `fetchLatest()` 轮询接口。
  - `refresh` 供下拉刷新使用，确保在网络波动时数据不会丢失。
