# 讲评模块说明

该目录实现错因聚合、典型题卡片与导出按钮等讲评页功能。

## 核心文件
- `presentation/review_page.dart`
  - 使用 `DefaultTabController` 提供“错因 TopN / 知识点”筛选，`TabBarView` 展示不同聚合列表。
  - `ReviewSummaryCard` 组件展示统计信息，调用 `AnalyticsService.trackGradingDuration` 记录讲评生成耗时。
  - “导出讲评”按钮触发 `_exportReview()`，通过 API 客户端调用后端导出接口，期间展示加载状态并处理 `ApiErrorException`。
  - 典型题卡片使用 `ExpansionTile` 呈现题目、解析与点评，支持大字模式下自动换行。
