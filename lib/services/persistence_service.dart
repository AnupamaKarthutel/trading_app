import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/models.dart';

class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  late SharedPreferences _prefs;

  static const _walletKey = 'wallet';
  static const _watchlistsKey = 'watchlists';
  static const _holdingsKey = 'holdings';
  static const _ordersKey = 'orders';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int loadWallet() => _prefs.getInt(_walletKey) ?? kInitialBalancePaisa;

  Future<void> saveWallet(int balance) => _prefs.setInt(_walletKey, balance);

  List<Watchlist> loadWatchlists() {
    final raw = _prefs.getString(_watchlistsKey);
    if (raw == null || raw.isEmpty) {
      return [Watchlist(id: _uuid(), name: 'My Watchlist', symbols: [])];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Watchlist.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveWatchlists(List<Watchlist> watchlists) {
    return _prefs.setString(
      _watchlistsKey,
      jsonEncode(watchlists.map((w) => w.toJson()).toList()),
    );
  }

  List<Holding> loadHoldings() {
    final raw = _prefs.getString(_holdingsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Holding.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveHoldings(List<Holding> holdings) {
    return _prefs.setString(
      _holdingsKey,
      jsonEncode(holdings.map((h) => h.toJson()).toList()),
    );
  }

  List<Order> loadOrders() {
    final raw = _prefs.getString(_ordersKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveOrders(List<Order> orders) {
    return _prefs.setString(
      _ordersKey,
      jsonEncode(orders.map((o) => o.toJson()).toList()),
    );
  }

  String _uuid() => DateTime.now().microsecondsSinceEpoch.toString();
}
