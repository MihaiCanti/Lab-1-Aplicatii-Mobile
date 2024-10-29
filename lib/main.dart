import 'package:flutter/material.dart';
import 'currency_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CurrencyConverter(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'EUR';
  String _toCurrency = 'MDL';
  double _result = 0.0;
  double _exchangeRate = 19.38;
  bool _isLoading = false;
  final CurrencyService _currencyService = CurrencyService();

  Future<void> _convertCurrency() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _currencyService.getRates(_fromCurrency);
      final rate = data['rates'][_toCurrency];

      setState(() {
        _exchangeRate = rate; // salvarea ratei valutare
        _result = (double.tryParse(_amountController.text) ?? 0.0) * rate; // claculam conversia pe baza ratei
      });
    } catch (e) {
      setState(() {
        _result = 0.0;
        _exchangeRate = 0.0; // Dacă apare o eroare, resetam rate-ul
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cantievschii Mihai'),
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Currency Converter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 20),

            // Card pentru conversie
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Eticheta "Amount" deasupra câmpului
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _fromCurrency,
                            onChanged: (String? newValue) {
                              setState(() {
                                _fromCurrency = newValue!;
                              });
                            },
                            items: _buildCurrencyItems(),
                          ),
                        ),
                      //  Converted Amount
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              // setam place-hold
                              hintText: "0.00",
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                            ),
                            textAlign: TextAlign.right, 
                            onTap: () {
                              // Dacă textul este "0.00" stergem la click
                              if (_amountController.text == "0.00") {
                                _amountController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Butonul swap 
                    ElevatedButton(
                      onPressed: _convertCurrency,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue,
                      ),
                      child: Transform.rotate(
                        angle: 90 * 3.1416 / 180, 
                        child: const Icon(Icons.swap_horiz, size: 24),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Eticheta "Converted Amount" deasupra câmpului
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Converted Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _toCurrency,
                            onChanged: (String? newValue) {
                              setState(() {
                                _toCurrency = newValue!;
                              });
                            },
                            items: _buildCurrencyItems(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              _isLoading ? 'Loading...' : _result.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right, 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Curs valutar indicativ
            const Text(
              'Indicative Exchange Rate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '1 $_fromCurrency = ${_exchangeRate.toStringAsFixed(2)} $_toCurrency',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCurrencyItems() {
    Map<String, String> currencyFlags = {
      'EUR': 'lib/imagini/EUR.png',
      'USD': 'lib/imagini/US.png',
      'MDL': 'lib/imagini/MDL.png',
      'RON': 'lib/imagini/RON.png',
      'RUB': 'lib/imagini/RUB.png',
    };

    return currencyFlags.keys.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Row(
          children: [
            Image.asset(currencyFlags[value]!, width: 42, height: 32),
            const SizedBox(width: 10),
            Text(value),
          ],
        ),
      );
    }).toList();
  }
}
