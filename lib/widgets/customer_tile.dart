import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../screens/customer_detail_screen.dart';
import 'auth_image.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  const CustomerTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Hero(
            tag: 'customer-avatar-${customer.id}',
            child: customer.imagePath != null ? AuthImage(imagePath: customer.imagePath, width: 56, height: 56, fit: BoxFit.cover) : Container(color: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.grey)),
          ),
        ),
      ),
      title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(customer.mobile ?? ''),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)),
            child: Text('Balance: ${customer.balance.toStringAsFixed(2)}', style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer))),
    );
  }
}
