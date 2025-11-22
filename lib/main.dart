import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'screens/login_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/home_decider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(api)),
      ],
      child: MaterialApp(
        title: 'Customer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: AppBarTheme(elevation: 0, centerTitle: true, backgroundColor: Colors.indigo.shade600, foregroundColor: Colors.white),
          cardTheme: CardTheme(elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), backgroundColor: Colors.indigo.shade600)),
          listTileTheme: ListTileThemeData(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.indigo.shade600),
        ),
        home: const HomeDecider(),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          CustomerListScreen.routeName: (_) => const CustomerListScreen(),
        },
      ),
    );
  }
}
