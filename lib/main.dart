import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ta'), Locale('hi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const LiveStockLensApp(),
    ),
  );
}

class LiveStockLensApp extends StatefulWidget {
  const LiveStockLensApp({super.key});

  @override
  State<LiveStockLensApp> createState() => _LiveStockLensAppState();
}

class _LiveStockLensAppState extends State<LiveStockLensApp> {
  String modelStatus = "Loading model...";
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('breed_model.tflite');
      setState(() {
        modelStatus = "Model loaded successfully ✅";
      });
    } catch (e) {
      setState(() {
        modelStatus = "Failed to load model ❌";
      });
      debugPrint("Error loading model: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LiveStock Lens',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: '/',
        routes: {
          '/': (context) => Scaffold(
            body: Center(child: Text(modelStatus)),
          ),
        },
        );
  }
}
