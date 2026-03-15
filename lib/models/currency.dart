class CurrencyDef {
  const CurrencyDef({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'is_active': 1,
    };
  }

  factory CurrencyDef.fromMap(Map<String, dynamic> map) {
    return CurrencyDef(
      code: map['code'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
    );
  }
}

class CurrencyCatalog {
  static const ron = CurrencyDef(
    code: 'RON',
    name: 'Romanian Leu',
    symbol: 'lei',
  );
  static const eur = CurrencyDef(code: 'EUR', name: 'Euro', symbol: '€');
  static const usd = CurrencyDef(code: 'USD', name: 'US Dollar', symbol: '\$');

  static const supported = <CurrencyDef>[ron, eur, usd];

  static String symbolFor(String code) {
    for (final currency in supported) {
      if (currency.code == code) {
        return currency.symbol;
      }
    }
    return code;
  }

  static String displayNameFor(String code) {
    for (final currency in supported) {
      if (currency.code == code) {
        return currency.name;
      }
    }
    return code;
  }
}
