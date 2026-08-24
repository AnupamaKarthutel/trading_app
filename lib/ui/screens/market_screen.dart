import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../services/market_data_service.dart';
import '../widgets/stock_price_row.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Tick rate',
            onPressed: () => _showTickRateSheet(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: kStocks.length,
        itemBuilder: (context, index) {
          final stock = kStocks[index];
          return StockPriceRow(
            key: ValueKey(stock.symbol),
            stock: stock,
          );
        },
      ),
    );
  }

  void _showTickRateSheet(BuildContext context) {
    const options = {
      'Relax (2 s)': 2000,
      'Normal (500 ms)': 500,
      'Fast (100 ms)': 100,
      'Stress (20 ms)': 20,
    };

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final currentMs = MarketDataService().tickInterval.inMilliseconds;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Mock tick interval',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...options.entries.map((entry) {
                  final ms = entry.value;
                  return RadioListTile<int>(
                    title: Text(entry.key),
                    value: ms,
                    groupValue: currentMs,
                    onChanged: (value) {
                      if (value != null) {
                        MarketDataService()
                            .setTickInterval(Duration(milliseconds: value));
                        setState(() {});
                      }
                    },
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
