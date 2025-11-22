import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@gmail.com');
  final _passCtrl = TextEditingController(text: 'admin1234');
  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // vibrant multi-stop gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFFFF416C), Color(0xFFFF4B1F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // colorful decorative blobs
          Positioned(left: -90, top: -80, child: Container(width: 220, height: 220, decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
          Positioned(right: -100, bottom: -120, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),
          Positioned(left: 40, bottom: 80, child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20)))),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: Colors.white.withOpacity(0.95),
                  elevation: 14,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // colorful logo badge
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF7043), Color(0xFFD32F2F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
                            ),
                            child: const Center(child: FlutterLogo(size: 48)),
                          ),
                          const SizedBox(height: 14),
                          Text('Welcome back,', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 6),
                          const Text('Sign in to continue to Customer Manager — manage customers easily', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email, color: Color(0xFF4A00E0)),
                              labelText: 'Email',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock, color: Color(0xFF8E2DE2)),
                              labelText: 'Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure = !_obscure)),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? true)),
                              const SizedBox(width: 6),
                              const Text('Remember me'),
                              const Spacer(),
                              TextButton(onPressed: () {}, child: const Text('Forgot?'))
                            ],
                          ),
                          if (auth.error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(auth.error!, style: const TextStyle(color: Colors.red))),
                          const SizedBox(height: 6),
                          // gradient sign-in button
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFFFF416C)]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 6))],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: auth.loading
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          final ok = await auth.login(username: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
                                          if (ok) Navigator.of(context).pushReplacementNamed('/customers');
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: auth.loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Sign in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: TextStyle(color: Colors.grey))), Expanded(child: Divider())]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                                label: const Text('Google'),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                icon: const Icon(Icons.apple),
                                label: const Text('Apple'),
                                onPressed: () {},
                              ),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          TextButton(onPressed: () {}, child: const Text('Create an account'))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
