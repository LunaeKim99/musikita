import 'package:flutter/material.dart';
import 'package:musikita/app.dart';
import 'package:musikita/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(const MusikitaApp());
}
