# 核心层说明

`lib/core/` 汇集跨业务共享的基础能力，包括配置、网络、离线队列、实时通信、工具与主题等模块。各子目录的 `comment.md` 已详细说明其职责，顶层文件如 `config.dart` 负责根据 `.env.*` 读取环境变量并向全局 Provider 暴露 `EnvConfig`。
