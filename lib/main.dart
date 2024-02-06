import 'dart:async';
import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'common/helper_ads/ads_lovin_utils.dart';
import 'translations/codegen_loader.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  // await AppLovinMAX.initialize(AdLovinUtils().keySdkApplovin);
  await EasyLocalization.ensureInitialized();
  if (Platform.isMacOS || Platform.isIOS) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyAsHmmSZaP5j9Oz-CJ5TJmNHYGE7TRyLXE',
            appId: '1:446060903157:ios:8bf334ad7335612a4a63bc',
            messagingSenderId: '446060903157',
            projectId: 'aigraphy'));
  } else {
    await Firebase.initializeApp(
        name: 'Face Swap Android',
        options: const FirebaseOptions(
          appId: '1:446060903157:android:dcde762055cddb854a63bc',
          apiKey: 'AIzaSyA-mxv6gE5JyAmXYyDPH4APcjR5rIo7JLU',
          projectId: 'aigraphy',
          authDomain: 'nodejs-ai-graphy.vercel.app',
          messagingSenderId: '446060903157',
        ));
  }

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('hi'),
        Locale('ja'),
        Locale('pt'),
        Locale('vi'),
        Locale('it'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: const CodegenLoader(),
      child: const MyApp()));
}
