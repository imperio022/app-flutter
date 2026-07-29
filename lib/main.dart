import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants.dart';
import 'core/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Inicializar ApiService para carregar token salvo do secure storage
  await ApiService().init();
  
  runApp(
    const ProviderScope(
      child: ImperioApp(),
    ),
  );
}
