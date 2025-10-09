# TODO

> 以下内容迁移自最初的 README，并在对应章节前标注进度。

- [x] **Flutter 自动批作业APP：原型图 + 技术选型 + 目录与架构（v1）**
  <details>
    <summary>展开查看原文</summary>

  > 目标：面向“拍照→OCR→解析→判分→报告”的移动端应用。本文给出**可落地**的原型草图、Flutter 技术选型、目录结构与分层架构，并附关键代码骨架。
  >
  > ## 快速开始（M0 原型）
  > 该仓库现已包含基于 Flutter 的最小可运行原型，覆盖 README 中的核心流程（作业列表 → 拍照上传 → 判分结果）。
  >
  > ### 运行步骤
  > 1. 安装 Flutter 3.22+ 与 Dart 3。
  > 2. 执行 `flutter pub get` 拉取依赖。
  > 3. 使用 `flutter run -t lib/main_dev.dart` 启动开发环境（或替换为 `main_stg.dart` / `main_prod.dart` 测试多环境配置）。
  >
  > ### 功能概览
  > - Material 3 主题、深浅色模式与 go_router 路由骨架。
  > - Riverpod 状态管理模拟 "queued → ocr → parsed → graded → reported" 提交流水线。
  > - 作业列表、拍照上传、判分结果页的最小 UI，便于后续接入真实后端。
  >
  > ---
  >
  > ## 1. 信息架构 & 用户流程
  >
  > ```
  > 学生/教师 → 登录/选择班级 → 作业列表 → (学生) 拍照提交 → 状态订阅 → 判分结果/解析
  >                                      ↘ (教师) 建作业/录答案 → 查看统计
  > ```
  >
  > **关键状态流**
  >
  > ```
  > queued → ocr → parsed → graded → reported
  > ```
  >
  > App 通过 WebSocket 订阅 `submissionId` 的状态并实时更新 UI。
  >
  > ---
  >
  > ## 2. 原型图（低保真草图）
  >
  > ...（原文保持不变，此处省略显示）
  >
  > ---
  >
  > ## 3. Flutter 技术选型（MVP→增强）
  >
  > ```dart
  > class SubmissionRepository {
  >   final Dio dio;
  >   SubmissionRepository(this.dio);
  >
  >   Future<PresignResp> presignUpload(String filename, int size) async {
  >     final r = await dio.post('/media/presign', data: {
  >       'filename': filename,
  >       'size': size,
  >     });
  >     return PresignResp.fromJson(r.data);
  >   }
  > }
  > ```
  >
  > ---
  >
  > ## 8. 路由（go_router）与导航
  >
  > ```dart
  > final router = GoRouter(
  >   routes: [
  >     GoRoute(path: '/', builder: (_, __) => const HomePage()),
  >     GoRoute(path: '/assignments', builder: (_, __) => const AssignmentListPage()),
  >     GoRoute(path: '/submit/:id', builder: (c, s) => SubmitPage(id: s.pathParameters['id']!)),
  >     GoRoute(path: '/result/:sid', builder: (c, s) => ResultPage(submissionId: s.pathParameters['sid']!)),
  >   ],
  > );
  > ```
  >
  > ---
  >
  > ## 9. Riverpod：提交流程 Provider（骨架）
  >
  > ```dart
  > @riverpod
  > class SubmissionController extends _$SubmissionController {
  >   @override
  >   Future<Submission?> build() async => null;
  >
  >   Future<String> create({required String assignmentId, required List<File> images}) async {
  >     // 1) 直传对象存储: presign → dio.put → 得到 keys
  >     // 2) 创建 submission（POST /submissions）→ 返回 submissionId
  >     // 3) 建立 WS 订阅，更新 state
  >     return 'submissionId';
  >   }
  >
  >   Stream<SubmissionStatus> subscribe(String submissionId) {
  >     // WebSocket 订阅服务端状态
  >     // 更新 state = state.copyWith(status: ...)
  >     throw UnimplementedError();
  >   }
  > }
  > ```
  >
  > ---
  >
  > ## 10. 拍照与预处理（要点）
  >
  > * **取景引导**：对齐边缘、光线过暗提示；批量连拍模式。
  > * **轻预处理**：压缩、去噪、透视矫正；控制单张上传大小（如 <1.5MB）。
  > * **可选模板标注**：教师端为“题区/答案区”画框，客户端带上坐标，后端可对区域做有针对的 OCR。
  >
  > ---
  >
  > ## 11. UI 组件与风格
  >
  > * **设计语言**：Material 3、强调易读/对比（Correct✅/错误❌高亮）。
  > * **语文结果高亮**：`RichText + TextSpan` 渲染错字（红底/下划线），缺漏（灰色占位），多写（删除线）。
  > * **数学等价说明**：展示 2~3 个采样点验证表格，增加可解释性。
  >
  > ---
  >
  > ## 12. 多环境与配置
  >
  > * `main_dev.dart / main_stg.dart / main_prod.dart` 区分 API 域名、日志级别。
  > * `.env`：`API_BASE_URL, WS_URL, S3_BUCKET, FEATURE_FLAGS`。
  > * 构建：`--dart-define-from-file=.env.prod`。
  >
  > ---
  >
  > ## 13. 权限与发布清单
  >
  > * Android：`CAMERA`, `READ/WRITE_EXTERNAL_STORAGE`（按需）、`INTERNET`。
  > * iOS：`NSCameraUsageDescription`、`NSPhotoLibraryAddUsageDescription`。
  > * 应用分发：内部测试（Firebase App Distribution/TestFlight）→ 灰度 → 正式。
  >
  > ---
  >
  > ## 14. 里程碑
  >
  > * **M0**：骨架搭建（目录、路由、主题、依赖注入、网络层）
  > * **M1**：拍照/批量上传/WS 状态订阅（闭环）
  > * **M2**：结果页（语文高亮/数学等价说明）+ 缓存与失败重试
  > * **M3**：教师端作业管理 + 题区模板标注 + 报表
  > * **M4**：离线判分兜底（可选）、UI 打磨、监控与埋点
  >
  > ---
  >
  > ### 附：依赖清单（示例）
  >
  > ```
  > dependencies:
  >   flutter:
  >     sdk: flutter
  >   go_router: ^14.0.0
  >   flutter_riverpod: ^3.0.0
  >   hooks_riverpod: ^3.0.0
  >   dio: ^5.7.0
  >   retrofit: ^4.0.0
  >   json_annotation: ^4.9.0
  >   freezed_annotation: ^2.4.0
  >   hive: ^2.2.0
  >   hive_flutter: ^1.1.0
  >   flutter_secure_storage: ^9.0.0
  >   camera: ^0.11.0
  >   image_picker: ^1.1.0
  >   image: ^4.2.0
  >   web_socket_channel: ^3.0.0
  >   intl: ^0.19.0
  >   logger: ^2.0.0
  >
  > dev_dependencies:
  >   build_runner: ^2.4.0
  >   freezed: ^2.4.0
  >   json_serializable: ^6.8.0
  >   flutter_test:
  >     sdk: flutter
  > ```

  </details>

- [ ] **面向后续迭代的需求列表**
  - [ ] 接入真实拍照/相册上传流程，包含批量处理与图像预处理能力。
  - [ ] 打通后端 API：作业列表、提交创建、WebSocket 状态订阅与判分结果查询。
  - [ ] 丰富结果页：语文错题高亮、数学等价性说明、知识点统计等细节展示。
  - [ ] 完善教师端功能：作业管理、答案录入、班级统计与导出能力。
  - [ ] 引入错误处理、重试与离线缓存机制，并补齐单元/集成测试。
  - [ ] 建立多环境配置与安全存储方案（.env、密钥管理、日志分级）。
  - [ ] 补充持续集成流程与质量保障（lint、格式化、自动化测试）。
