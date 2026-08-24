import 'package:flutter/material.dart';

import 'services/market_data_service.dart';
import 'services/persistence_service.dart';
import 'ui/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistenceService().init();
  MarketDataService().start();
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}
