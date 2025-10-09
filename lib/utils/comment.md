# 通用工具说明

该目录当前包含图片预处理逻辑，供上传模块复用。

## `image_preprocess.dart`
- `ImagePreprocessor` 提供 `process` 方法，按顺序执行裁边、去噪、压缩、灰度等步骤，返回 `ImageProcessResult`。
- `ImageProcessResult` 记录原始/处理后大小与压缩比，供 UI 展示。
- 各步骤使用可注入的策略函数（`_autoCrop`、`_denoise` 等），便于未来替换为原生或第三方实现。
- 默认实现通过 `image` 包的 `copyCrop`、`gaussianBlur`、`grayscale` 等 API 保证处理结果肉眼可读且单页不超过 5MB。
