# 核心工具模块说明

该目录包含跨业务的工具类，用于全局埋点与多语言管理。

## 关键文件
- `analytics.dart`
  - `AnalyticsEvent` 定义埋点事件结构（`name`、`properties`、`timestamp`）。
  - `AnalyticsService` 通过依赖注入使用 `Logger` 输出事件，并预留 `dispatch` 接口供未来接入第三方分析平台。
  - `trackLoginSuccess`、`trackSubmission`、`trackGradingDuration` 等方法封装常用事件，确保字段命名一致。
- `locale_controller.dart`
  - `LocaleController` 使用 `StateNotifier<Locale?>` 管理当前语言，`setLocale` 支持在运行时切换并缓存到 `SharedPreferences`。
  - `loadInitialLocale` 会在启动时读取系统或缓存语言，保证 `MaterialApp` 初始化后即可应用正确的 `Locale`。
