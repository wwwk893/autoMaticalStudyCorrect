# 鉴权模块说明

该目录负责邮箱/手机号登录流程、会话管理以及设置页入口。

## 结构概览
- `domain/session.dart`：定义 `Session` 数据模型，包含 `accessToken`、`refreshToken`、`expiredAt` 等字段，用于描述当前登录态。
- `data/session_repository.dart`：封装 `FlutterSecureStorage` 的读写，`loadSession` 在应用启动时恢复 Token，`saveSession`/`clearSession` 负责持久化。
- `data/auth_repository.dart`：使用 `ApiClient` 调用后端登录与刷新接口，并将返回结果交给 `SessionRepository` 存储。
- `application/auth_controller.dart`：Riverpod `StateNotifier` 驱动 UI，`signIn` 协程在成功后调用 `apiClient.updateAuthToken` 并触发导航；`restoreSession` 在冷启动时检查 Token 是否有效。
- `presentation/login_page.dart`：实现邮箱/手机号 Tab 切换、验证码输入、按钮状态等交互；内部通过 `Form` + `TextEditingController` 校验输入。
- `presentation/settings_page.dart`：提供“绑定微信账号（需管理员开通）”提示及占位按钮，点击后跳转到预留的引导界面。

## 关键交互
- `AuthController` 构造函数中注册 `apiClient.registerUnauthorizedHandler`，当服务端返回 401 且 `ErrorInterceptor` 解析成功时，自动执行 `signOut` 并跳转登录页。
- `restoreSession` 完成后会在 `state.isAuthenticated` 为真时导航至主页面，实现冷启动自动登录。
