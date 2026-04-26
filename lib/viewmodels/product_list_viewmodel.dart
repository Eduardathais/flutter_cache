import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

enum ViewState { idle, loading, success, error }

class ProductListViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ViewState _state = ViewState.idle;
  List<Product> _products = [];
  String? _errorMessage;

  ViewState get state => _state;
  List<Product> get products => List.unmodifiable(_products);
  String? get errorMessage => _errorMessage;

  ProductListViewModel(this._repository);

  Future<void> loadProducts() async {
    if (_state == ViewState.loading) return;
    _update(ViewState.loading, errorMessage: null);

    try {
      _products = await _repository.fetchProducts();
      _update(ViewState.success);
    } catch (e) {
      _update(ViewState.error, errorMessage: 'Falha ao carregar produtos: $e');
    }
  }

  void _update(ViewState state, {String? errorMessage}) {
    _state = state;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}
