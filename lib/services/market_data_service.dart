import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../data/models.dart';

/// The single source of truth for live market data.
///
/// Each symbol has its own [ValueNotifier] so UI cells can listen to exactly
/// one symbol without rebuilding when unrelated prices change.
class MarketDataService {
  static final MarketDataService _instance = MarketDataService._internal();
  factory MarketDataService() => _instance;
  MarketDataService._internal();

  final _random = Random();
  final Map<String, ValueNotifier<PriceTick>> _notifiers = {};

  Timer? _timer;
  Duration _tickInterval = const Duration(milliseconds: 200);

  final ValueNotifier<int> tickCounter = ValueNotifier<int>(0);

  Duration get tickInterval => _tickInterval;

  /// Starts emitting ticks. Safe to call repeatedly to restart with a new rate.
  void start() {
    for (final stock in kStocks) {
      _notifiers[stock.symbol] ??= ValueNotifier<PriceTick>(
        PriceTick(stock.basePaisa, TickDirection.none, DateTime.now()),
      );
    }
    _timer?.cancel();
    _timer = Timer.periodic(_tickInterval, (_) => _tickOne());
  }

  void stop() => _timer?.cancel();

  ValueNotifier<PriceTick> priceNotifier(String symbol) {
    return _notifiers[symbol]!;
  }

  int currentPrice(String symbol) => _notifiers[symbol]!.value.pricePaisa;

  void setTickInterval(Duration interval) {
    _tickInterval = interval;
    start();
  }

  void _tickOne() {
    final symbols = kStocks.map((s) => s.symbol).toList();
    final symbol = symbols[_random.nextInt(symbols.length)];

    final current = _notifiers[symbol]!.value.pricePaisa;
    int delta = _random.nextInt(11) - 5; // -5 to +5 paisa
    if (delta == 0) delta = _random.nextBool() ? 1 : -1;

    int newPrice = current + delta;
    if (newPrice < 1) newPrice = 1;

    final direction = newPrice > current
        ? TickDirection.up
        : (newPrice < current ? TickDirection.down : TickDirection.none);

    _notifiers[symbol]!.value = PriceTick(newPrice, direction, DateTime.now());
    tickCounter.value = tickCounter.value + 1;
  }
}
