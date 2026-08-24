import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../../services/market_data_service.dart';

class HoldingsRow extends StatelessWidget {
  final Holding holding;
  final VoidCallback onTap;

  const HoldingsRow({super.key, required this.holding, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stock = stockBySymbol(holding.symbol);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        dense: true,
        onTap: onTap,
        title: Text(
          holding.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${holding.quantity} @ ${formatCurrency(holding.avgCostPaisa)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: ValueListenableBuilder<PriceTick>(
          valueListenable: MarketDataService().priceNotifier(stock.symbol),
          builder: (context, tick, _) {
            final currentValue = holding.quantity * tick.pricePaisa;
            final invested = holding.quantity * holding.avgCostPaisa;
            final pnl = currentValue - invested;
            final pnlPct = invested == 0 ? 0.0 : pnl / invested * 100.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(currentValue),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${formatCurrencySigned(pnl)} (${formatPercentage(pnlPct)})',
                  style: TextStyle(
                    color: profitColor(context, pnl),
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
