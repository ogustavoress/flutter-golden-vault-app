import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _goHome();
    } catch (e) {
      _showError("Erro ao entrar: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _goHome();
    } catch (e) {
      _showError("Falha ao registrar: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFD72638),
      ),
    );
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: const Color(0xFF1B1B1B),
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      "assets/lottie/login.json",
                      width: 140,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Golden Vault",
                      style: TextStyle(
                        fontFamily: "PlayfairDisplay",
                        color: Color(0xFFD4AF37),
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      label: "E-mail",
                      validator: (v) =>
                          v == null || v.isEmpty ? "Digite o e-mail" : null,
                    ),
                    const SizedBox(height: 14),

                    // Senha
                    CustomTextField(
                      controller: _passwordController,
                      label: "Senha",
                      obscure: _isObscure,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Digite sua senha" : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFD4AF37),
                        ),
                        onPressed: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                    ),
                    const SizedBox(height: 26),

                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFFD4AF37),
                          )
                        : Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.black,
                                  minimumSize:
                                      const Size(double.infinity, 50),
                                ),
                                onPressed: _signIn,
                                child: const Text("Entrar"),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFD4AF37), width: 2),
                                  foregroundColor:
                                      const Color(0xFFD4AF37),
                                  minimumSize:
                                      const Size(double.infinity, 50),
                                ),
                                onPressed: _signUp,
                                child: const Text("Registrar"),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}