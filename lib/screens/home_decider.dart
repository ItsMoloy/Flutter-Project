import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'customer_list_screen.dart';

class HomeDecider extends StatelessWidget {
  const HomeDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      // If token is loaded and present, go to customer list
      if (auth.token != null && auth.token!.isNotEmpty) {
        return const CustomerListScreen();
      }
      // Otherwise show login
      return const LoginScreen();
    });
  }
}
