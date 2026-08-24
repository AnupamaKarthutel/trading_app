import 'package:flutter/foundation.dart';

import '../data/models.dart';
import 'persistence_service.dart';

class WatchlistService extends ChangeNotifier {
  static final WatchlistService _instance = WatchlistService._internal();
  factory WatchlistService() => _instance;

  final List<Watchlist> _watchlists;
  int _currentIndex;

  WatchlistService._internal()
      : _watchlists = PersistenceService().loadWatchlists(),
        _currentIndex = 0;

  List<Watchlist> get watchlists => List.unmodifiable(_watchlists);
  Watchlist get current => _watchlists[_currentIndex];
  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    if (value >= 0 && value < _watchlists.length) {
      _currentIndex = value;
      notifyListeners();
    }
  }

  Future<void> create(String name) async {
    _watchlists.add(Watchlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Watchlist' : name.trim(),
      symbols: [],
    ));
    _currentIndex = _watchlists.length - 1;
    await _save();
    notifyListeners();
  }

  Future<void> rename(int index, String name) async {
    _watchlists[index].name = name.trim().isEmpty ? 'Watchlist' : name.trim();
    await _save();
    notifyListeners();
  }

  Future<void> delete(int index) async {
    _watchlists.removeAt(index);
    if (_watchlists.isEmpty) {
      _watchlists.add(Watchlist(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'My Watchlist',
        symbols: [],
      ));
    }
    if (_currentIndex >= _watchlists.length) {
      _currentIndex = _watchlists.length - 1;
    }
    if (_currentIndex < 0) _currentIndex = 0;
    await _save();
    notifyListeners();
  }

  Future<void> addSymbol(String symbol) async {
    if (!current.symbols.contains(symbol)) {
      current.symbols.add(symbol);
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeSymbolAt(int index) async {
    current.symbols.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = current.symbols.removeAt(oldIndex);
    current.symbols.insert(newIndex, item);
    await _save();
    notifyListeners();
  }

  Future<void> _save() => PersistenceService().saveWatchlists(_watchlists);
}
