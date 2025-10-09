# 自动生成的 API 客户端说明

该目录用于存放由 `tools/openapi/generate_dart_client.sh` 脚本生成的 Dart API 客户端源码，目前仓库内通过 `placeholder.dart` 表示生成物位置。

## 关键约定
- 生成产物会以 `package:dio` 为底层网络库，与 `lib/core/network/api_client.dart` 中的通用配置保持一致。
- 文件结构遵循 `openapi-generator` 的命名惯例，包含 `api/`、`model/` 等子目录，便于在 feature 模块中引入强类型接口模型。
- 若需扩展自定义模板，可在脚本中追加 `--additional-properties` 参数，本目录不应手动修改生成文件，所有改动应通过更新 OpenAPI 描述或生成配置完成。
