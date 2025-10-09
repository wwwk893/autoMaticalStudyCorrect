import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('zh'), Locale('en')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('zh'));
  }

  bool get isChinese => locale.languageCode == 'zh';

  String get appTitle => isChinese ? '自动批作业' : 'Auto Grader';
  String get loginTitle => isChinese ? '登录' : 'Sign in';
  String get emailLabel => isChinese ? '邮箱' : 'Email';
  String get phoneLabel => isChinese ? '手机号' : 'Phone';
  String get passwordLabel => isChinese ? '密码' : 'Password';
  String get loginButton => isChinese ? '立即登录' : 'Continue';
  String get invalidForm => isChinese ? '请填写完整信息' : 'Please fill in all fields';
  String get logout => isChinese ? '退出登录' : 'Log out';
  String get settingsTitle => isChinese ? '设置' : 'Settings';
  String get bindWeChat =>
      isChinese ? '绑定微信账号（需管理员开通）' : 'Bind WeChat account (admin only)';
  String get bindWeChatDescription => isChinese
      ? '请联系管理员开启小程序账号绑定权限。'
      : 'Contact an administrator to enable mini program account binding.';
  String get retry => isChinese ? '重试' : 'Retry';
  String get cancel => isChinese ? '取消' : 'Cancel';
  String get upload => isChinese ? '上传' : 'Upload';
  String get review => isChinese ? '讲评' : 'Review';
  String get assignments => isChinese ? '作业列表' : 'Assignments';
  String get offlineQueue => isChinese ? '离线队列' : 'Offline queue';
  String get queueEmpty => isChinese ? '暂无离线任务' : 'No offline tasks';
  String get tokenExpired => isChinese ? '登录状态已过期' : 'Session expired';
  String get progress => isChinese ? '进度' : 'Progress';
  String get refresh => isChinese ? '刷新' : 'Refresh';
  String get homeGreeting =>
      isChinese ? '开始你的智能批改体验' : 'Start your smart grading journey';
  String get language => isChinese ? '语言' : 'Language';
  String get languageChinese => isChinese ? '中文' : 'Chinese';
  String get languageEnglish => isChinese ? '英文' : 'English';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
