# 集成测试说明

该目录包含端到端流程验证脚本，覆盖“拍照 → 上传 → 进度 → 结果”的关键路径。

## `full_flow_test.dart`
- 使用 `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` 启动测试环境。
- 通过模拟拍照与上传操作验证 `UploadController` 状态转移，检查离线队列与重试逻辑是否触发。
- 订阅 `SubmissionController` 的状态流，确保实时进度从 `queued` 演进到 `reported`。
- 最终断言结果页展示的讲评入口，保证整个学习闭环可用。
