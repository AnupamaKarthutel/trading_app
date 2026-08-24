import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../../services/market_data_service.dart';

class StockPriceRow extends StatelessWidget {
  final Stock stock;

  const StockPriceRow({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: _PriceListener(stock: stock),
    );
  }
}

class _PriceListener extends StatelessWidget {
  final Stock stock;

  const _PriceListener({required this.stock});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PriceTick>(
      valueListenable: MarketDataService().priceNotifier(stock.symbol),
      builder: (context, tick, _) => _PriceCell(stock: stock, tick: tick),
    );
  }
}

class _PriceCell extends StatefulWidget {
  final Stock stock;
  final PriceTick tick;

  const _PriceCell({required this.stock, required this.tick});

  @override
  State<_PriceCell> createState() => _PriceCellState();
}

class _PriceCellState extends State<_PriceCell> {
  Color _flashColor = Colors.transparent;
  Timer? _flashTimer;

  @override
  void didUpdateWidget(covariant _PriceCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tick.pricePaisa > oldWidget.tick.pricePaisa) {
      _triggerFlash(Colors.green);
    } else if (widget.tick.pricePaisa < oldWidget.tick.pricePaisa) {
      _triggerFlash(Colors.red);
    }
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  void _triggerFlash(MaterialColor color) {
    _flashTimer?.cancel();
    setState(() => _flashColor = color.withOpacity(0.12));
    _flashTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _flashColor = Colors.transparent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final change = widget.tick.pricePaisa - widget.stock.basePaisa;
    final pct = change / widget.stock.basePaisa * 100.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: _flashColor,
      child: ListTile(
        dense: true,
        title: Text(
          widget.stock.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          widget.stock.name,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(widget.tick.pricePaisa),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${formatCurrencySigned(change)} (${formatPercentage(pct)})',
              style: TextStyle(
                color: profitColor(context, change),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
