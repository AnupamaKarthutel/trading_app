import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../core/utils.dart';
import '../data/models.dart';
import 'persistence_service.dart';

class PortfolioService extends ChangeNotifier {
  static final PortfolioService _instance = PortfolioService._internal();
  factory PortfolioService() => _instance;

  late int _balancePaisa;
  final List<Holding> _holdings = [];
  final List<Order> _orders = [];

  PortfolioService._internal() {
    _load();
  }

  void _load() {
    _balancePaisa = PersistenceService().loadWallet();
    _holdings.addAll(PersistenceService().loadHoldings());
    _orders.addAll(PersistenceService().loadOrders());
  }

  int get balancePaisa => _balancePaisa;
  List<Holding> get holdings => List.unmodifiable(_holdings);
  List<Order> get orders => List.unmodifiable(_orders);

  Holding? _findHolding(String symbol) {
    for (final h in _holdings) {
      if (h.symbol == symbol) return h;
    }
    return null;
  }

  String? validateOrder({
    required OrderSide side,
    required String symbol,
    required int quantity,
    required int currentPricePaisa,
  }) {
    if (quantity <= 0) return 'Enter a valid positive quantity';

    final totalPaisa = quantity * currentPricePaisa;

    if (side == OrderSide.buy) {
      if (totalPaisa > _balancePaisa) {
        return 'Insufficient balance. Available: ${formatCurrency(_balancePaisa)}';
      }
    } else {
      final holding = _findHolding(symbol);
      if (holding == null || holding.quantity < quantity) {
        return 'Cannot sell more than held (${holding?.quantity ?? 0})';
      }
    }
    return null;
  }

  Future<Order> placeOrder({
    required OrderSide side,
    required String symbol,
    required int quantity,
    required int pricePaisa,
  }) async {
    final totalPaisa = quantity * pricePaisa;
    final now = DateTime.now();
    final order = Order(
      id: now.microsecondsSinceEpoch.toString(),
      symbol: symbol,
      side: side,
      quantity: quantity,
      pricePaisa: pricePaisa,
      totalPaisa: totalPaisa,
      placedAt: now,
    );

    if (side == OrderSide.buy) {
      _balancePaisa -= totalPaisa;
      _addOrUpdateBuyHolding(symbol, quantity, pricePaisa);
    } else {
      _balancePaisa += totalPaisa;
      _reduceHolding(symbol, quantity);
    }

    _orders.insert(0, order);

    await PersistenceService().saveWallet(_balancePaisa);
    await PersistenceService().saveHoldings(_holdings);
    await PersistenceService().saveOrders(_orders);

    notifyListeners();
    return order;
  }

  void _addOrUpdateBuyHolding(String symbol, int quantity, int pricePaisa) {
    final existing = _findHolding(symbol);
    if (existing == null) {
      _holdings.add(Holding(
        symbol: symbol,
        quantity: quantity,
        avgCostPaisa: pricePaisa,
      ));
      return;
    }
    final totalQty = existing.quantity + quantity;
    final totalCost = (existing.quantity * existing.avgCostPaisa) +
        (quantity * pricePaisa);
    existing.avgCostPaisa = totalCost ~/ totalQty;
    existing.quantity = totalQty;
  }

  void _reduceHolding(String symbol, int quantity) {
    final existing = _findHolding(symbol);
    if (existing == null) return;
    existing.quantity -= quantity;
    if (existing.quantity <= 0) {
      _holdings.removeWhere((h) => h.symbol == symbol);
    }
  }
}
