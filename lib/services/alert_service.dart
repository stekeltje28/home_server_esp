import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertService {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;

  AlertService() {
    _navigationService = _getIt.get<NavigationService>();
  }

  void showToast({IconData icon = Icons.info, required String text}) {
    try {
      DelightToastBar(
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
        position: DelightSnackbarPosition.top,
        builder: (context) {
          return ToastCard(
            leading: Icon(icon, size: 28),
            title: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          );
        },
      ).show(_navigationService.navigatorKey.currentContext!);
    } catch (e) {
      print(e);
    }
  }

  Future<void> setRememberMe(bool remember) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember_me', remember);
  }

  Future<bool> getRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }
}
