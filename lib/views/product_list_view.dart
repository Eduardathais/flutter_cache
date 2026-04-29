import 'package:flutter/material.dart';

import '../cache/product_memory_cache.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../viewmodels/product_list_viewmodel.dart';
import 'product_detail_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  late final ProductListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductListViewModel(ProductRepository(ProductMemoryCache()));
    _viewModel.loadProducts();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailView(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _viewModel.loadProducts,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Column(
            children: [
              if (_viewModel.state == ViewState.loading)
                const LinearProgressIndicator(),
              Expanded(
                child: switch (_viewModel.state) {
                  ViewState.idle => const SizedBox.shrink(),
                  ViewState.loading => const SizedBox.shrink(),
                  ViewState.error => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _viewModel.errorMessage ?? 'Erro desconhecido',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _viewModel.loadProducts,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ViewState.success => ListView.separated(
                      itemCount: _viewModel.products.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = _viewModel.products[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.thumbnail,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 72,
                                height: 72,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          title: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${product.category} • R\$ ${product.price.toStringAsFixed(2)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openDetail(product),
                        );
                      },
                    ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
