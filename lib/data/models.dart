import '../core/constants.dart';

enum TickDirection { up, down, none }

class PriceTick {
  final int pricePaisa;
  final TickDirection direction;
  final DateTime at;

  PriceTick(this.pricePaisa, this.direction, this.at);
}

enum OrderSide { buy, sell }

class Watchlist {
  String id;
  String name;
  List<String> symbols;

  Watchlist({
    required this.id,
    required this.name,
    required this.symbols,
  });

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      id: json['id'] as String,
      name: json['name'] as String,
      symbols: List<String>.from(json['symbols'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbols': symbols,
      };
}

class Holding {
  String symbol;
  int quantity;
  int avgCostPaisa;

  Holding({
    required this.symbol,
    required this.quantity,
    required this.avgCostPaisa,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] as String,
      quantity: json['quantity'] as int,
      avgCostPaisa: json['avgCostPaisa'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'avgCostPaisa': avgCostPaisa,
      };
}

class Order {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final int pricePaisa;
  final int totalPaisa;
  final DateTime placedAt;

  Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.pricePaisa,
    required this.totalPaisa,
    required this.placedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      side: OrderSide.values.byName(json['side'] as String),
      quantity: json['quantity'] as int,
      pricePaisa: json['pricePaisa'] as int,
      totalPaisa: json['totalPaisa'] as int,
      placedAt: DateTime.parse(json['placedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'side': side.name,
        'quantity': quantity,
        'pricePaisa': pricePaisa,
        'totalPaisa': totalPaisa,
        'placedAt': placedAt.toIso8601String(),
      };
}

/// Convenience helpers that derive change information from the configured base.
extension StockChange on PriceTick {
  int changePaisa(String symbol) => pricePaisa - stockBySymbol(symbol).basePaisa;

  double changePercent(String symbol) {
    final base = stockBySymbol(symbol).basePaisa;
    return (pricePaisa - base) / base * 100.0;
  }
}
