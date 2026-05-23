import 'package:flutter/material.dart';
import 'package:musikita/app.dart';
import 'package:musikita/core/di/injection_container.dart';
import 'package:musikita/features/music_player/data/datasources/local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  final localDataSource = sl<LocalDataSource>();
  await localDataSource.init();

  runApp(const MusikitaApp());
}
