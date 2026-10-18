import 'package:flutter/material.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/splash/presentation/widgets/splash_view_body.dart';

class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
    this.authCubit,
    this.storageService,
    this.minSplashDuration = const Duration(milliseconds: 2200),
  });

  final AuthCubit? authCubit;
  final StorageService? storageService;
  final Duration minSplashDuration;

  @override
  Widget build(BuildContext context) {
    return SplashViewBody(
      authCubit: authCubit,
      storageService: storageService,
      minSplashDuration: minSplashDuration,
    );
  }
}
