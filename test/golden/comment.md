# Golden 测试资源说明

该目录存放 UI Golden 测试用的基准资源与测试代码，确保关键界面在迭代中保持像素一致。

## 内容概览
- `golden_test.dart`
  - 在执行前自动从 `.png.b64` 文本基准解码生成 PNG，规避直接提交二进制文件导致的评审阻塞。
  - 覆盖作业卡、上传进度条、讲评页三个核心 UI，并在断言后清理临时生成的 PNG。
- Base64 资源
  - `assignment_card.png.b64`：作业卡片默认态基准（Base64 编码文本）。
  - `upload_progress.png.b64`：分块上传过程中每页进度展示基准。
  - `review_page.png.b64`：讲评页筛选与典型题卡片布局基准。
