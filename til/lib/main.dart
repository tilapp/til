import 'package:flutter/material.dart';
import 'package:til/settings/sign_in.dart';
import 'package:til/views/app.dart';
import 'package:til/settings/settings_controller.dart';
import 'package:til/settings/settings_service.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  await signInAs(email: '', password: '');
  runApp(TILApp(settingsController: settingsController));
}
