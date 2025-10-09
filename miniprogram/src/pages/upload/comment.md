# 上传页说明

- `index.ts`：维护选中图片列表与模拟上传进度，`onUpload` 中循环调用 Mock API 并更新状态。
- `index.wxml`：使用 `scroll-view` 展示图片缩略图与排序按钮，底部提供“开始上传”操作。
- `index.wxss`：定义栅格布局与进度条样式，适配窄屏设备。
- `index.json`：配置导航栏标题与分享能力。
