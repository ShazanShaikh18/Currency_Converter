import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient{
  final Uri currencyURL = Uri.https("free.currconv.com", "/api/v7/currencies", {"apiKey":"4f6ef6f6c136f9f2e860"});
  // The first parameter of URI should be just the main url, without http, any kind
  // The second parameter will be the endpoint path
  // The third parameter is a map for the different properties

  // Function to get the Currencies list
  Future<List<String>> getCurrencies() async {
    final response = await http.get(currencyURL);

    if(response.statusCode == 200){
      var body = jsonDecode(response.body);
      var list = body["results"];
      List<String> currencies = (list.keys).toList();
      print(currencies);
      return currencies;
    }else{
      throw Exception("Failed to connect to API");
    }
  }
}