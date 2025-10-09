# 自动批作业前端

该仓库提供 Flutter App 与微信小程序的前端基线，围绕“合同驱动”迭代展开。仓库已经内置 OpenAPI 客户端生成脚本、鉴权会话管理、上传通道、实时进度、讲评页等模块的骨架，并支持多环境配置与测试脚手架。

## 快速开始

### 依赖
- Flutter 3.22 与 Dart 3
- `melos`（可选，便于多端脚本统一执行）
- Docker（用于运行 OpenAPI 代码生成器）

### 环境配置
1. 复制 `.env.example` 到 `.env.dev`、`.env.stg`、`.env.prod` 并根据环境替换 API 与实时服务地址。
2. 通过 `flutter pub get` 安装依赖。
3. 根据目标环境执行：
   - `flutter run -t lib/main_dev.dart`
   - `flutter run -t lib/main_stg.dart`
   - `flutter run -t lib/main_prod.dart`

默认会通过 `lib/core/config.dart` 自动读取 `APP_FLAVOR` 并加载对应的 `EnvConfig`。

### 开发流程速览
- 生成 Dart OpenAPI 客户端：`tools/openapi/generate_dart_client.sh https://<backend-domain>`
- 生成小程序 TypeScript 客户端：`npm run gen:mp-sdk`
- 运行集成测试：`flutter test integration_test`
- 运行 Golden 对比：`flutter test --update-goldens test/golden`

更多脚本和检查项见 [TEST.md](TEST.md)。

## 目录结构

```
├── lib
│   ├── api/generated           # OpenAPI 生成的 Dart 客户端
│   ├── core
│   │   ├── config.dart         # 多环境配置加载
│   │   ├── network             # 统一的 APIClient 与错误拦截器
│   │   ├── offline_queue       # 离线上传队列
│   │   └── realtime            # WebSocket + 轮询兜底
│   ├── features
│   │   ├── auth                # 鉴权与 token 存储
│   │   ├── upload              # 预处理、分块直传
│   │   ├── submission          # 任务状态机与进度
│   │   └── review              # 讲评页
│   └── utils                   # 图像预处理等工具
├── integration_test            # 拍照→上传→进度→结果集成测试
├── test/golden                 # Golden 图
├── miniprogram                 # 小程序骨架与 SDK
└── tools/openapi               # 客户端代码生成脚本
```

## 常见问题

- **如何切换语言？** 设置中的语言切换会更新 `AppLocalizations` 并触发 UI 重建。英文文案与中文一致保持格式，不会引起布局错乱。
- **如何排查后端错误？** 所有接口统一通过 `ErrorInterceptor` 捕获 `{code,message,traceId}` 结构的错误，App 会展示友好提示并在调试日志中打印 `traceId`。
- **如何验证弱网策略？** 上传模块提供指数退避重试策略，可在开发环境通过 `NetworkLinkConditioner` 或 `adb` 模拟丢包、断网。

更多验收细节记录在 [TEST.md](TEST.md)。
