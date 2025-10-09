# 小程序骨架说明

该目录为未来小程序客户端预留的代码骨架与 SDK 生成工具。

## 结构概览
- `package.json`：定义 `npm run gen:mp-sdk` 指令，调用 `scripts/gen-sdk.js` 生成 TypeScript 客户端到 `sdk/generated/`。
- `scripts/gen-sdk.js`：使用 `openapi-typescript-codegen` 读取同一份 OpenAPI 描述，保持与 Flutter 端一致的接口模型。
- `src/pages/`：包含 `login`、`upload`、`status` 三个页面的最小 Mock 逻辑，可在微信开发者工具中验证登录→上传→查看状态的流程。
- `sdk/generated/`：放置生成的 TS 客户端（当前以 README 占位）。
