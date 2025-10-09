# 实时通信模块说明

该目录抽象了 WebSocket 与轮询的实时订阅逻辑，用于追踪作业进度。

## 核心文件
- `realtime_client.dart`
  - `RealtimeClient` 管理 WebSocket 连接，`connect` 方法根据 `EnvConfig.realtimeUrl` 构建地址并开启监听。
  - 当 `WebSocketChannel` 抛出异常或连接关闭时，`_scheduleReconnect` 启动指数退避重连，并在多次失败后切换为轮询模式。
  - `listen` 返回 `StreamSubscription`，内部对消息进行 JSON 解析，解析失败时写入日志而不会中断流。
  - `RealtimeTransport` 枚举描述当前传输方式，`_transportController` 使用 `StreamController.broadcast` 以便 UI 显示当前状态（WS / Polling）。
