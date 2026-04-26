import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductRepository {
  static const _url = 'https://dummyjson.com/products?limit=30';

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(seconds: 2));

    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar produtos (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>;
    return list
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
