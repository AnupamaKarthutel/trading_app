import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../../services/market_data_service.dart';
import '../../services/portfolio_service.dart';
import 'order_confirmation_screen.dart';

class BuySellScreen extends StatefulWidget {
  final String symbol;
  final OrderSide? initialSide;

  const BuySellScreen({
    super.key,
    required this.symbol,
    this.initialSide,
  });

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> {
  final _quantityController = TextEditingController();
  OrderSide _side = OrderSide.buy;

  @override
  void initState() {
    super.initState();
    _side = widget.initialSide ?? OrderSide.buy;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = stockBySymbol(widget.symbol);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.symbol} - Order')),
      body: ValueListenableBuilder<PriceTick>(
        valueListenable: MarketDataService().priceNotifier(widget.symbol),
        builder: (context, tick, _) {
          final qty = int.tryParse(_quantityController.text);
          final projected = (qty ?? 0) * tick.pricePaisa;
          final error = _computeError(qty, tick);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(stock, tick),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Buy'),
                        selected: _side == OrderSide.buy,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _side = OrderSide.buy);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Sell'),
                        selected: _side == OrderSide.sell,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _side = OrderSide.sell);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    errorText: error,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text(
                  'Estimated value: ${formatCurrency(projected)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Available balance: ${formatCurrency(PortfolioService().balancePaisa)}',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: error == null && qty != null
                      ? () => _submit(qty, tick.pricePaisa)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _side == OrderSide.buy
                        ? Colors.green
                        : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _side == OrderSide.buy
                        ? 'Buy ${widget.symbol}'
                        : 'Sell ${widget.symbol}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Stock stock, PriceTick tick) {
    final change = tick.pricePaisa - stock.basePaisa;
    final pct = change / stock.basePaisa * 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.name,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'LTP: ${formatCurrency(tick.pricePaisa)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${formatCurrencySigned(change)} (${formatPercentage(pct)})',
              style: TextStyle(
                color: profitColor(context, change),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _computeError(int? qty, PriceTick tick) {
    if (qty == null || _quantityController.text.isEmpty) {
      return null;
    }
    if (qty <= 0) return 'Quantity must be positive';
    return PortfolioService().validateOrder(
      side: _side,
      symbol: widget.symbol,
      quantity: qty,
      currentPricePaisa: tick.pricePaisa,
    );
  }

  Future<void> _submit(int qty, int pricePaisa) async {
    final order = await PortfolioService().placeOrder(
      side: _side,
      symbol: widget.symbol,
      quantity: qty,
      pricePaisa: pricePaisa,
    );
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: order),
        ),
      );
    }
  }
}
