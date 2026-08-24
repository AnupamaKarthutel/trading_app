import 'package:flutter/material.dart';

import '../../core/utils.dart';
import '../../data/models.dart';
import '../../services/market_data_service.dart';
import '../../services/portfolio_service.dart';
import '../widgets/holdings_row.dart';
import 'buy_sell_screen.dart';

enum SortMode { pnlDesc, symbolAsc, valueDesc }

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  SortMode _sort = SortMode.pnlDesc;

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: _sort == SortMode.symbolAsc
          ? PortfolioService()
          : Listenable.merge([PortfolioService(), MarketDataService().tickCounter]),
      builder: (context, _) {
        final holdings = _sortHoldings(PortfolioService().holdings);

        if (holdings.isEmpty) {
          return const Center(child: Text('No holdings yet. Place a buy order.'));
        }

        return ListView.builder(
          itemCount: holdings.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SummaryCard();
            }
            final holding = holdings[index - 1];
            return HoldingsRow(
              key: ValueKey(holding.symbol),
              holding: holding,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BuySellScreen(symbol: holding.symbol),
                ),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holdings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SortMode>(
                value: _sort,
                style: Theme.of(context).textTheme.titleSmall,
                icon: const Icon(Icons.sort),
                items: const [
                  DropdownMenuItem(
                    value: SortMode.pnlDesc,
                    child: Text('P&L'),
                  ),
                  DropdownMenuItem(
                    value: SortMode.symbolAsc,
                    child: Text('Symbol'),
                  ),
                  DropdownMenuItem(
                    value: SortMode.valueDesc,
                    child: Text('Value'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _sort = value);
                },
              ),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  List<Holding> _sortHoldings(List<Holding> holdings) {
    final sorted = List<Holding>.from(holdings);
    switch (_sort) {
      case SortMode.pnlDesc:
        sorted.sort((a, b) {
          final pnlA = _pnl(a);
          final pnlB = _pnl(b);
          return pnlB.compareTo(pnlA);
        });
        break;
      case SortMode.symbolAsc:
        sorted.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
      case SortMode.valueDesc:
        sorted.sort((a, b) {
          final valA = _value(a);
          final valB = _value(b);
          return valB.compareTo(valA);
        });
        break;
    }
    return sorted;
  }

  int _pnl(Holding h) {
    final ltp = MarketDataService().currentPrice(h.symbol);
    final currentValue = h.quantity * ltp;
    final invested = h.quantity * h.avgCostPaisa;
    return currentValue - invested;
  }

  int _value(Holding h) {
    final ltp = MarketDataService().currentPrice(h.symbol);
    return h.quantity * ltp;
  }
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([PortfolioService(), MarketDataService().tickCounter]),
      builder: (context, _) {
        int invested = 0;
        int currentValue = 0;

        for (final h in PortfolioService().holdings) {
          final ltp = MarketDataService().currentPrice(h.symbol);
          invested += h.quantity * h.avgCostPaisa;
          currentValue += h.quantity * ltp;
        }

        final pnl = currentValue - invested;
        final pnlPct = invested == 0 ? 0.0 : pnl / invested * 100.0;

        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Portfolio Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _row('Invested', formatCurrency(invested)),
                _row('Current value', formatCurrency(currentValue)),
                _row('P&L', '${formatCurrencySigned(pnl)} (${formatPercentage(pnlPct)})',
                    color: profitColor(context, pnl)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
