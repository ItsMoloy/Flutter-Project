import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService api;
  List<Customer> customers = [];
  bool loading = false;
  String? error;
  int pageNo = 1;
  final int pageSize;
  bool hasMore = true;
  String searchQuery = '';

  CustomerProvider(this.api, {this.pageSize = 20});

  Future<void> refresh() async {
    pageNo = 1;
    customers.clear();
    hasMore = true;
    await fetchNext();
  }

  Future<void> fetchNext() async {
    if (!hasMore || loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await api.getCustomerList(searchQuery: searchQuery, pageNo: pageNo, pageSize: pageSize);
      if (res.containsKey('error') && res['error'] == true) {
        error = res['message'] ?? 'Failed to load customers';
        hasMore = false;
        return;
      }
      final data = res['data'] ?? res;
      List<dynamic> list = [];
      if (data is List) list = data;
      else if (data is Map && data['Customers'] is List) list = data['Customers'];
      else if (data is Map && data['Data'] is List) list = data['Data'];
      else if (data is Map && data['List'] is List) list = data['List'];

      // If the server returned an object wrapping the list under other keys
      if (list.isEmpty && data is Map) {
        // try to find the first list value
        for (final v in data.values) {
          if (v is List) {
            list = v;
            break;
          }
        }
        if (list.isEmpty) {
          // ignore: avoid_print
          print('CustomerProvider: no list found in response, keys: ${data.keys.toList()} raw: $data');
        }
      }

      final fetched = list.map((e) {
        try {
          return Customer.fromJson(e as Map<String, dynamic>);
        } catch (err) {
          // ignore: avoid_print
          print('Failed to parse customer entry: $err -- raw: $e');
          return null;
        }
      }).whereType<Customer>().toList();
      if (pageNo == 1) customers = fetched; else customers.addAll(fetched);
      if (fetched.length < pageSize) hasMore = false; else pageNo++;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
