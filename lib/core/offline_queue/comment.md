# 离线队列模块说明

该目录负责管理弱网或离线状态下的任务排队与恢复。

## 关键类
- `OfflineQueueTask`
  - 构造函数自动分配 UUID（`Uuid().v4()`）并记录创建时间，用于追踪离线任务。
  - `toJson` / `fromJson` 实现通过 `SharedPreferences` 序列化存储。
- `OfflineQueueController`
  - 初始化阶段 `_restore()` 从本地存储读取 `_queueKey` 对应的任务列表并恢复成状态流。
  - `enqueue` 在入队后调用 `_persist`，保证内存与本地数据同步。
  - `markComplete` 与 `bumpAttempt` 分别用于任务完成与指数退避计数更新，配合上传模块实现重传逻辑。
- `offlineQueueControllerProvider`
  - 使用 `StateNotifierProvider` 暴露可观察状态，页面或其他 Service 可以订阅任务数量并在网络恢复时触发续传。
