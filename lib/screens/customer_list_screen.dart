import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/customer_tile.dart';

class CustomerListScreen extends StatefulWidget {
  static const routeName = '/customers';
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    provider.refresh();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels > _scrollCtrl.position.maxScrollExtent - 200) {
        provider.fetchNext();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Manager'),
        actions: [
          IconButton(
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search customers by name or email...'),
                    onChanged: (q) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                        final prov = Provider.of<CustomerProvider>(context, listen: false);
                        prov.searchQuery = q;
                        prov.refresh();
                      });
                    },
                    onSubmitted: (q) {
                      _searchDebounce?.cancel();
                      final prov = Provider.of<CustomerProvider>(context, listen: false);
                      prov.searchQuery = q;
                      prov.refresh();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    final prov = Provider.of<CustomerProvider>(context, listen: false);
                    prov.searchQuery = '';
                    prov.refresh();
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(builder: (context, prov, _) {
              if (prov.loading && prov.customers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (prov.error != null && prov.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: ${prov.error}'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: prov.refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      )
                    ],
                  ),
                );
              }
              if (prov.customers.isEmpty) {
                return Center(child: Text(prov.loading ? 'Loading customers...' : 'No customers found'));
              }
              return RefreshIndicator(
                onRefresh: prov.refresh,
                child: ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: prov.customers.length + (prov.hasMore ? 1 : 0),
                  itemBuilder: (context, idx) {
                    if (idx >= prov.customers.length) {
                      if (prov.error != null) return ListTile(title: Text('Error: ${prov.error}'));
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final c = prov.customers[idx];
                    return CustomerTile(customer: c);
                  },
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
