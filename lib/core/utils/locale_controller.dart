import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('zh'));

  void switchTo(Locale locale) {
    state = locale;
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});
