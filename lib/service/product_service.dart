import 'package:dio/dio.dart';
import '../models/product.dart';

class PagedProducts {
  final List<Product> items;
  final int total;
  PagedProducts(this.items, this.total);
}

class ProductService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<PagedProducts> fetchProducts({
    int limit = 20,
    int skip = 0,
    String? category,
    String? query,
    String? sortBy,
    String? order,
  }) async {
    String path = '/products';

    if (query != null && query.trim().isNotEmpty) {
      path = '/products/search';
    } else if (category != null && category != 'all') {
      path = '/products/category/$category';
    }

    final queryParams = <String, dynamic>{'limit': limit, 'skip': skip};

    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (order != null && order.isNotEmpty) {
      queryParams['order'] = order;
    }

    final res = await _dio.get(path, queryParameters: queryParams);

    final list = (res.data['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    final total = res.data['total'] as int? ?? list.length;
    return PagedProducts(list, total);
  }

  Future<List<String>> fetchCategories() async {
    final res = await _dio.get('/products/categories');
    return (res.data as List)
        .map((e) => e is Map ? e['slug'] as String : e.toString())
        .toList();
  }

  Future<Product> fetchProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data as Map<String, dynamic>);
  }
}
