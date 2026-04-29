import 'dart:convert';

import 'package:http/http.dart' as http;

import '../cache/product_memory_cache.dart';
import '../models/product.dart';

class ProductRepository {
  static const _url = 'https://dummyjson.com/products?limit=30';

  final ProductMemoryCache _cache;

  ProductRepository(this._cache);

  Future<List<Product>> fetchProducts() async {
    final cached = _cache.getIfValid();
    if (cached != null) return cached;

    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar produtos (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>;
    final products = list
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();

    _cache.save(products);
    return products;
  }

  void clearCache() => _cache.clear();
}
