# Trading App Flutter Assignment

A realtime-ish mock trading app built with Flutter. It demonstrates watchlist management, a configurable mock market-data feed, live P&L in holdings, and a simulated buy/sell order ticket.

## Run instructions

```bash
cd trading_app
flutter pub get
flutter run
```

> If the platform folders (`android/`, `ios/`, `web/`, etc.) are not present, generate them once with `flutter create .` before running the commands above.

## Architecture

```
lib/
  core/       # constants and formatting helpers
  data/       # models (Watchlist, Holding, Order, PriceTick)
  services/   # persistence, market-data feed, portfolio, watchlists
  ui/         # screens and reusable widgets
```

All money values are stored as **paisa** integers (`1 INR = 100 paisa`) so wallet, order and P&L math is precise. The market feed exposes one `ValueNotifier<PriceTick>` per symbol, so only the updated price cell rebuilds.

## Features

1. **Watchlist** – create/rename/delete multiple watchlists, add from the 10 configured stocks, drag to reorder, remove, and tap a row to open the ticket.
2. **Live Prices** – continuously updating prices with green/red flash, configurable tick rate via the tune icon.
3. **Buy/Sell Ticket** – quantity entry with inline validation, live LTP, balance/margin checks for buys and holding checks for sells, confirmation screen.
4. **Holdings** – live P&L, sortable by P&L / symbol / value, aggregate portfolio summary, tap a holding to trade it.

Data is persisted with `shared_preferences` and survives app restarts.
