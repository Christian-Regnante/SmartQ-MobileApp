import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
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

  // Set transparent status bar overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

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

class _SmartQAppState extends State<SmartQApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
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
      ),
    );
  }
}
