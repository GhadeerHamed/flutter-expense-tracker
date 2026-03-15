import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String _baseUrl = 'https://api.frankfurter.app/latest';

  Future<Map<String, double>> fetchRatesToRon(Set<String> currencyCodes) async {
    final codes = currencyCodes.map((code) => code.toUpperCase()).toSet();
    codes.add('RON');

    final ratesToRon = <String, double>{'RON': 1.0};

    for (final code in codes) {
      if (code == 'RON') {
        continue;
      }

      final uri = Uri.parse('$_baseUrl?from=$code&to=RON');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        continue;
      }

      final Map<String, dynamic> jsonBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic>? rates =
          jsonBody['rates'] as Map<String, dynamic>?;
      final rate = rates?['RON'];
      if (rate is num) {
        ratesToRon[code] = rate.toDouble();
      }
    }

    return ratesToRon;
  }
}
