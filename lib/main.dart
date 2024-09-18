import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CurrencyConverterPage(),
    );
  }
}


class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  double _conversionRate = 0.0;
  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';
  List<String> _currencies = [];
  Map<String, String> _flags = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
    _fetchConversionRate();
  }

  Future<void> _fetchCurrencies() async {
    final url = 'https://restcountries.com/v3.1/all';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final currencies = <String>[];
      final flags = <String, String>{};

      for (var country in data) {
        if (country['currencies'] != null) {
          for (var currency in country['currencies'].keys) {
            if (!currencies.contains(currency)) {
              currencies.add(currency);
              final flagUrl = country['flags']['svg'] as String;
              flags[currency] = flagUrl;
            }
          }
        }
      }

      setState(() {
        _currencies = currencies;
        _flags = flags;
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  Future<void> _fetchConversionRate() async {
    final url = 'https://api.exchangerate-api.com/v4/latest/$_fromCurrency';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _conversionRate = data['rates'][_toCurrency];
      });
    } else {
      throw Exception('Failed to load conversion rate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                _buildFlagDropdown('From', _fromCurrency, (String? newValue) {
                  setState(() {
                    _fromCurrency = newValue!;
                    _fetchConversionRate();
                  });
                }),
                SizedBox(width: 16),
                _buildFlagDropdown('To', _toCurrency, (String? newValue) {
                  setState(() {
                    _toCurrency = newValue!;
                    _fetchConversionRate();
                  });
                }),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                final convertedAmount = amount * _conversionRate;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Converted Amount', style: TextStyle(fontWeight: FontWeight.bold),),
                    content: Text('${_toCurrency} ${convertedAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18),),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Text('Convert', style: TextStyle(color: Colors.black),),style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.teal.shade100),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagDropdown(String label, String value, void Function(String?)? onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: _currencies.map((currencyCode) {
          return DropdownMenuItem<String>(
            value: currencyCode,
            child: Row(
              children: [
                _flags.containsKey(currencyCode)
                    ? SvgPicture.network(
                  _flags[currencyCode]!,
                  width: 30,
                  height: 20,
                )
                    : Container(),
                SizedBox(width: 8),
                Text(currencyCode),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}