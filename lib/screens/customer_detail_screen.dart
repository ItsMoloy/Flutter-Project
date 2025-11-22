import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../widgets/auth_image.dart';

class CustomerDetailScreen extends StatelessWidget {
  static const routeName = '/customer-detail';
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (customer.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: Hero(tag: 'customer-avatar-${customer.id}', child: AuthImage(imagePath: customer.imagePath, fit: BoxFit.cover, width: double.infinity, height: 200)),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Mobile: ${customer.mobile ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('Balance: ${customer.balance.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
