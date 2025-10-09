# 上传模块说明

该目录覆盖图片预处理、分块直传、失败重试与离线续传逻辑。

## 关键文件
- `data/upload_repository.dart`
  - `requestPresignedParts` 调用生成的 API 客户端获取分块上传所需的预签名 URL 列表。
  - `uploadPart` 使用 `dio` 直接将文件分片 PUT 到对象存储，支持重试钩子。
  - `completeUpload` 通知后端合并分块并返回最终资源 ID。
- `application/upload_controller.dart`
  - 负责整体状态机，`prepareAndUpload` 流程中调用 `ImagePreprocessor`（`lib/utils/image_preprocess.dart`）进行裁边、降噪、压缩并在 UI 展示压缩比。
  - 对每个分片调用 `_uploadWithRetry`：采用指数退避（基于 `attempt` 次数计算延迟）最多重试 3 次，失败则写入 `OfflineQueue`。
  - 监听 `Connectivity` 与 `OfflineQueue` 状态，在网络恢复时调用 `resumePendingTasks` 续传。
- `presentation/upload_page.dart`
  - 提供多页上传 UI，支持拖拽排序（`ReorderableListView`）、删除、进度展示，并在提交后实时更新每页状态。
