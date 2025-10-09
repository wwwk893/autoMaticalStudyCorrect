# OpenAPI 工具脚本说明

该目录提供前后端契约驱动开发所需的 Dart 客户端生成脚本。

## 核心文件
- `generate_dart_client.sh`：封装 `openapi-generator` 的调用，读取 `http(s)://<backend>/openapi/v1/openapi.yaml` 并输出到 `lib/api/generated/`。脚本中：
  - 通过 `SCRIPT_DIR` 与 `REPO_ROOT` 推导项目根路径，确保在任意路径下执行都能定位仓库根目录。
  - 使用 `DEFAULT_SPEC` 与可选参数允许开发者覆盖默认的 OpenAPI 地址。
  - 调用 `openapi-generator-cli` 时显式传入 `pubspec.yaml` 中声明的输出目录，并设置 `pubName`/`pubDescription` 以便生成的包在 Flutter 项目内引用。
  - 生成完成后执行 `dart format` 保证代码风格一致，如需在无 Dart SDK 环境下执行，脚本也会优雅跳过格式化并给出提示。
