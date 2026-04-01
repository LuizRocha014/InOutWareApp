import 'dart:io';

import 'package:componentes_lr/componentes_lr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/config/app_routes.dart';
import 'package:in_out_ware_app/core/infra/init.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:window_size/window_size.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initAppInfos(isOptional: true);

  await initContext();

  initSaleAppInstances();
  initStockAppInstances();
  initTransferAppInstances();

  if (Platform.isWindows) {
    setWindowTitle('InOutWareApp');
    setWindowMaxSize(Size.infinite);
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: 375,
        height: 812,
      ));
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppRoutes(context: context);

    return GetMaterialApp(
      title: 'InOutWareApp',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      getPages: AppRoutes.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E2238)),
        useMaterial3: true,
      ),
      builder: (context, widget) {
        AppMeasurements.setAppMeasurements(context);
        return ResponsiveWrapper.builder(
          ClampingScrollWrapper.builder(context, widget!),
          minWidth: 375,
          breakpoints: [
            const ResponsiveBreakpoint.autoScale(375, name: MOBILE),
          ],
          defaultScale: true,
        );
      },
    );
  }
}
