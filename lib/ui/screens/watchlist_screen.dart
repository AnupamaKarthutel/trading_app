import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../../services/market_data_service.dart';
import '../../services/watchlist_service.dart';
import 'buy_sell_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WatchlistService(),
      builder: (context, _) {
        final service = WatchlistService();
        final watchlist = service.current;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Watchlist'),
            actions: [
              IconButton(
                icon: const Icon(Icons.playlist_add),
                tooltip: 'New watchlist',
                onPressed: () => _createWatchlist(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Rename',
                onPressed: () => _renameWatchlist(context, service.currentIndex),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _deleteWatchlist(context, service.currentIndex),
              ),
            ],
          ),
          body: Column(
            children: [
              _WatchlistSelector(
                index: service.currentIndex,
                items: service.watchlists,
                onChanged: (index) => service.currentIndex = index!,
              ),
              Expanded(
                child: watchlist.symbols.isEmpty
                    ? const Center(child: Text('This watchlist is empty. Add stocks below.'))
                    : ReorderableListView.builder(
                        itemCount: watchlist.symbols.length,
                        onReorder: (oldIndex, newIndex) =>
                            service.reorder(oldIndex, newIndex),
                        itemBuilder: (context, index) {
                          final symbol = watchlist.symbols[index];
                          return _WatchlistRow(
                            key: ValueKey(symbol),
                            symbol: symbol,
                            onRemove: () => _removeSymbol(symbol),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddStockDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<String?> _showInputDialog(BuildContext context,
      {required String title, required String initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _createWatchlist(BuildContext context) async {
    final name = await _showInputDialog(context,
        title: 'New watchlist', initial: '');
    if (name != null && name.isNotEmpty) {
      WatchlistService().create(name);
    }
  }

  void _renameWatchlist(BuildContext context, int index) async {
    final name = await _showInputDialog(context,
        title: 'Rename watchlist',
        initial: WatchlistService().watchlists[index].name);
    if (name != null) {
      WatchlistService().rename(index, name);
    }
  }

  void _deleteWatchlist(BuildContext context, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      WatchlistService().delete(index);
    }
  }

  void _removeSymbol(String symbol) {
    final service = WatchlistService();
    final index = service.current.symbols.indexOf(symbol);
    if (index != -1) service.removeSymbolAt(index);
  }

  void _showAddStockDialog(BuildContext context) {
    final current = WatchlistService().current;
    final available = kStocks
        .where((s) => !current.symbols.contains(s.symbol))
        .toList();

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add stock'),
        children: available.isEmpty
            ? [const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('All 10 stocks are already in this watchlist.'),
              )]
            : available
                .map((stock) => SimpleDialogOption(
                      onPressed: () {
                        WatchlistService().addSymbol(stock.symbol);
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        dense: true,
                        title: Text(stock.symbol),
                        subtitle: Text(stock.name),
                      ),
                    ))
                .toList(),
      ),
    );
  }
}

class _WatchlistSelector extends StatelessWidget {
  final int index;
  final List<Watchlist> items;
  final ValueChanged<int?> onChanged;

  const _WatchlistSelector({
    required this.index,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.playlist_play, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<int>(
              value: index,
              isExpanded: true,
              underline: const SizedBox(),
              items: items.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value.name),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistRow extends StatelessWidget {
  final String symbol;
  final VoidCallback onRemove;

  const _WatchlistRow({
    required Key? key,
    required this.symbol,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = stockBySymbol(symbol);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ValueListenableBuilder<PriceTick>(
        valueListenable: MarketDataService().priceNotifier(symbol),
        builder: (context, tick, _) {
          final change = tick.pricePaisa - stock.basePaisa;
          final pct = change / stock.basePaisa * 100.0;
          return ListTile(
            dense: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BuySellScreen(symbol: symbol),
              ),
            ),
            title: Text(
              symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              stock.name,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(tick.pricePaisa),
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
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
