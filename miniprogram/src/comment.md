# 小程序源码目录说明

`src/` 目录包含基于 Mock 数据的最小可运行小程序页面。

- `pages/login`：提供账号/验证码输入与登录按钮，调用本地 Mock API 返回 Session。
- `pages/upload`：模拟选择图片与进度展示，展示分块上传流程的 UI 结构。
- `pages/status`：根据 Mock 任务数据渲染状态时间线，与 Flutter 端状态机保持一致。

未来可在此基础上接入真实接口或扩展更多页面。
