import 'package:flutter/material.dart';
import 'package:index_pharma_store/core/theme/theme.dart';
import 'package:index_pharma_store/core/utils/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IndexPharmaApp());
}

class IndexPharmaApp extends StatelessWidget {
  const IndexPharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Index Pharma Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}

