import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Filter out transient Flutter web engine assertions and background platform socket errors
  FlutterError.onError = (FlutterErrorDetails details) {
    final err = details.exception.toString();
    if (err.contains('ViewInsets cannot be negative') || err.contains('DEVELOPER_ERROR')) {
      return;
    }
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    final errStr = error.toString();
    if (errStr.contains('ViewInsets cannot be negative') ||
        errStr.contains('DEVELOPER_ERROR') ||
        errStr.contains('Software caused connection abort') ||
        errStr.contains('Broken pipe')) {
      return true;
    }
    return false;
  };

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Dependency Injection
  await initServiceLocator();

  runApp(const SmartQApp());
}

class SmartQApp extends StatefulWidget {
  const SmartQApp({super.key});

  @override
  State<SmartQApp> createState() => _SmartQAppState();
}

class _SmartQAppState extends State<SmartQApp> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final ThemeCubit _themeCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authBloc = sl<AuthBloc>();
    _themeCubit = sl<ThemeCubit>();
    _appRouter = AppRouter(authBloc: _authBloc);
    _syncStatusBar(_themeCubit.isDarkMode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authBloc.close();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _themeCubit.syncSystemBrightness(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  void _syncStatusBar(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
      ],
      child: BlocConsumer<ThemeCubit, ThemeMode>(
        listener: (context, mode) {
          final isDark = mode == ThemeMode.dark ||
              (mode == ThemeMode.system &&
                  WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                      Brightness.dark);
          AppColors.applyBrightness(isDark ? Brightness.dark : Brightness.light);
          _syncStatusBar(isDark);
        },
        builder: (context, themeMode) {
          final isDark = themeMode == ThemeMode.dark ||
              (themeMode == ThemeMode.system &&
                  WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                      Brightness.dark);
          AppColors.applyBrightness(isDark ? Brightness.dark : Brightness.light);

          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _appRouter.router,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              final safeViewInsets = EdgeInsets.fromLTRB(
                mediaQuery.viewInsets.left < 0 ? 0 : mediaQuery.viewInsets.left,
                mediaQuery.viewInsets.top < 0 ? 0 : mediaQuery.viewInsets.top,
                mediaQuery.viewInsets.right < 0 ? 0 : mediaQuery.viewInsets.right,
                mediaQuery.viewInsets.bottom < 0 ? 0 : mediaQuery.viewInsets.bottom,
              );
              return MediaQuery(
                data: mediaQuery.copyWith(viewInsets: safeViewInsets),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
