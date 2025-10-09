# 验收与测试清单

## 0. 基线
- [ ] `git checkout feat/contract-driven-frontend` 切换到功能分支。
- [ ] `flutter analyze` 确认静态检查通过。

## 1. OpenAPI 客户端
- [ ] 运行 `tools/openapi/generate_dart_client.sh https://<backend>/openapi/v1/openapi.yaml` 生成 `lib/api/generated` 目录。
- [ ] 确认脚本执行后 Dart 客户端代码可通过 `dart format` 与 `dart analyze`。

## 2. 鉴权与会话
- [ ] 启动 App 后登录邮箱/手机号，冷启动后 Token 自动注入请求头。
- [ ] Token 失效时自动跳转登录页。
- [ ] 设置页展示“绑定微信账号（需管理员开通）”说明。

## 3. 上传与弱网
- [ ] 通过预签名直传上传大图，观察分块并有 3 次指数退避重试。
- [ ] 上传前展示裁边、去噪、压缩、灰度后的压缩比。
- [ ] 断网时任务进入离线队列，重连后自动续传。

## 4. 任务状态机与实时进度
- [ ] 列表、详情页均显示 `queued→ocr→parsed→graded→reported` 状态徽章。
- [ ] WebSocket 中断后自动切换轮询；恢复时回到 WS 不重复弹窗。

## 5. 多页作业与讲评
- [ ] 拍摄多页后可拖拽排序、删除，提交顺序与服务端返回一致。
- [ ] 讲评页支持“错因 TopN / 知识点”筛选，导出按钮调用后端。

## 6. 本地化与无障碍
- [ ] 切换到英文后页面布局正常。
- [ ] 系统字体放大 125% 时各页面无溢出、控件可触达。

## 7. 测试质量
- [ ] `flutter test integration_test` 跑通拍照→上传→进度→结果流程。
- [ ] `flutter test test/golden` Golden 对比通过。

## 8. 小程序
- [ ] `npm run gen:mp-sdk` 生成 `miniprogram/sdk/generated`。
- [ ] 在开发者工具中打开 `miniprogram` 目录，Mock 流程可完成登录→上传→状态查看。

## 9. 发布配置
- [ ] 多 Flavor `.env.*` 切换无需改代码即可运行。
- [ ] 崩溃与埋点能采集登录成功、提交次数、评分耗时。
