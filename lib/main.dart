import 'package:biometric_signature/android_config.dart';
import 'package:biometric_signature/ios_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sp_sharia_stock/features/home/views/home_page.dart';
import 'package:biometric_signature/biometric_signature.dart';

import 'features/home/data/repository/stock_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _biometricSignature = BiometricSignature();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    try {
      final String? biometricsType =
          await _biometricSignature.biometricAuthAvailable();
      debugPrint("biometricsType : $biometricsType");
      final bool doExist =
          await _biometricSignature.biometricKeyExists(checkValidity: true) ??
          false;
      debugPrint("doExist : $doExist");
      if (!doExist) {
        await _biometricSignature.createKeys(
          androidConfig: AndroidConfig(useDeviceCredentials: true),
          iosConfig: IosConfig(useDeviceCredentials: false),
        );
      }
      final signatureResult = await _biometricSignature.createSignature(
        options: {
          "payload": "Biometric payload",
          "promptMessage": "Authenticate to access the app",
          "shouldMigrate": "true",
          "allowDeviceCredentials": "true",
        },
      );

      if (signatureResult != null) {
        setState(() {
          _isAuthenticated = true;
        });
      }
    } on PlatformException catch (e) {
      debugPrint(e.message);
      debugPrint(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SP Sharia Stock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:
          _isAuthenticated
              ? RepositoryProvider<StockRepository>(
                create: (context) => StockRepository(),
                child: HomePage(),
              )
              : const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              ),
    );
  }
}
