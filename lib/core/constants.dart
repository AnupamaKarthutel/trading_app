/// Every price, balance and order value in the app is stored as an integer
/// number of paisa (1 rupee = 100 paisa). This avoids floating-point drift.
class Stock {
  final String symbol;
  final String name;
  final int basePaisa;

  const Stock({
    required this.symbol,
    required this.name,
    required this.basePaisa,
  });
}

const List<Stock> kStocks = [
  Stock(symbol: 'RELIANCE', name: 'Reliance Industries', basePaisa: 245000),
  Stock(symbol: 'TCS', name: 'Tata Consultancy Services', basePaisa: 330000),
  Stock(symbol: 'INFY', name: 'Infosys', basePaisa: 145000),
  Stock(symbol: 'HDFCBANK', name: 'HDFC Bank', basePaisa: 162000),
  Stock(symbol: 'ICICIBANK', name: 'ICICI Bank', basePaisa: 110000),
  Stock(symbol: 'SBIN', name: 'State Bank of India', basePaisa: 68000),
  Stock(symbol: 'ITC', name: 'ITC Limited', basePaisa: 45000),
  Stock(symbol: 'LT', name: 'Larsen & Toubro', basePaisa: 310000),
  Stock(symbol: 'BHARTIARTL', name: 'Bharti Airtel', basePaisa: 85000),
  Stock(symbol: 'AXISBANK', name: 'Axis Bank', basePaisa: 98000),
];

const int kInitialBalancePaisa = 100000000; // 1,000,000 INR

Stock stockBySymbol(String symbol) {
  return kStocks.firstWhere((s) => s.symbol == symbol);
}
