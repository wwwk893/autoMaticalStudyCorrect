# 网络层说明

该目录封装了应用的通用网络访问能力，包括环境配置、鉴权注入与错误处理。

## 核心组件
- `api_client.dart`
  - `apiClientProvider`：Riverpod Provider 负责创建单例 `ApiClient`，自动读取 `EnvConfig` 并注册销毁回调。
  - `ApiClient` 构造函数中设置 `Dio` 的 `BaseOptions`（超时时间、Base URL、JSON Content-Type），并注入两个拦截器：
    - `ErrorInterceptor` 将服务端约定的 `{code,message,traceId}` 结构转换为 `ApiErrorException`，统一处理逻辑错误。
    - `QueuedInterceptorsWrapper` 在请求阶段附加 `Authorization` Header，`updateAuthToken` 方法由鉴权流程调用以刷新 Token。
  - `registerUnauthorizedHandler` 提供回调，当拦截器捕获到 401 并解析出 `ApiError` 时触发，用于触发重新登录逻辑。
- `error_interceptor.dart`
  - `ApiError` 结构体记录服务端返回的业务错误与 `traceId`，`ApiErrorException` 继承 `DioException` 以兼容现有异常管线。
  - `onResponse` 钩子针对 HTTP 200 但业务失败的场景（`code != 0`）直接 reject，避免上层误认为成功。
  - `onError` 钩子会解析响应体中的错误结构，记录日志并在 401 状态下调用未授权回调，实现 token 失效自动退出。
