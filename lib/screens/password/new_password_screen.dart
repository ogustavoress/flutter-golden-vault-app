import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../widgets/password_result_widget.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool includeUpper = true;
  bool includeNumbers = true;
  bool includeSymbols = true;
  double length = 12;

  String? generatedPassword;
  bool _isLoading = false;

  Future<void> generatePassword() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
        "https://safekey-api-a1bd9aa97953.herokuapp.com/generate-password?"
        "length=${length.toInt()}&"
        "upper=$includeUpper&"
        "numbers=$includeNumbers&"
        "symbols=$includeSymbols");

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      setState(() {
        generatedPassword = data["password"] ?? "Erro";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha ao gerar senha: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> savePassword() async {
    if (generatedPassword == null) return;

    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Salvar Senha',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Digite um rótulo",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text("Salvar"),
            onPressed: () async {
              if (controller.text.isEmpty) return;

              final user = FirebaseAuth.instance.currentUser!;
              await FirebaseFirestore.instance.collection("passwords").add({
                "userId": user.uid,
                "password": generatedPassword,
                "label": controller.text,
                "createdAt": Timestamp.now(),
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Senha salva com sucesso!"),
                  backgroundColor: Color(0xFFD4AF37),
                ),
              );

              Navigator.pop(context); // volta à Home
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          "Gerar nova senha",
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Color(0xFFD4AF37)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Golden Vault - Segurança de outro nível"),
                backgroundColor: Color(0xFFD4AF37),
              ));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: generatedPassword != null ? savePassword : null,
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset("assets/lottie/loading.json", width: 150),
              const SizedBox(height: 20),

              if (generatedPassword == null)
                const Text(
                  "Configure e gere sua senha",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

              if (generatedPassword != null)
                PasswordResultWidget(password: generatedPassword!),

              // Slider comprimento
              const SizedBox(height: 24),
              Text(
                "Tamanho: ${length.toInt()}",
                style: const TextStyle(color: Colors.white70),
              ),
              Slider(
                value: length,
                min: 8,
                max: 32,
                divisions: 24,
                activeColor: const Color(0xFFD4AF37),
                onChanged: (value) =>
                    setState(() => length = value),
              ),

              // Switches
              _buildSwitch("Letras maiúsculas", includeUpper,
                  (v) => setState(() => includeUpper = v)),
              _buildSwitch("Números", includeNumbers,
                  (v) => setState(() => includeNumbers = v)),
              _buildSwitch("Símbolos", includeSymbols,
                  (v) => setState(() => includeSymbols = v)),

              const SizedBox(height: 28),

              _isLoading
                  ? const CircularProgressIndicator(
                      color: Color(0xFFD4AF37))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        minimumSize:
                            const Size(double.infinity, 50),
                      ),
                      onPressed: generatePassword,
                      child: const Text("Gerar Senha"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label,
          style: const TextStyle(color: Colors.white70)),
      value: value,
      activeColor: const Color(0xFFD4AF37),
      onChanged: onChanged,
    );
  }
}