import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../new_password/new_password_screen.dart';
import '../login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  bool _showPasswords = false;

  Stream<QuerySnapshot> _loadItems() {
    return FirebaseFirestore.instance
        .collection("passwords")
        .where("userId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  void _deleteItem(String id) {
    FirebaseFirestore.instance.collection("passwords").doc(id).delete();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          "Bem-vindo, ${user.email}",
          style: const TextStyle(color: Color(0xFFD4AF37)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
            onPressed: _logout,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFD4AF37), width: 2),
              ),
              child: Row(
                children: [
                  Lottie.asset("assets/lottie/home.json", width: 60),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Versão Premium ativada 🏆",
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _loadItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: Lottie.asset("assets/lottie/loading.json"));
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Erro ao carregar dados.",
                      style: TextStyle(color: Color(0xFFD72638)),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nenhuma senha cadastrada ainda.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final item = docs[i];
                    final password = item["password"] ?? "••••••••";
                    final label = item["label"] ?? "Sem nome";

                    return Card(
                      color: const Color(0xFF1B1B1B),
                      margin:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _showPasswords ? password : "••••••••",
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            _showPasswords
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFFD4AF37),
                          ),
                          onPressed: () {
                            setState(() => _showPasswords = !_showPasswords);
                          },
                        ),
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Senha copiada!"),
                              backgroundColor: Color(0xFFD4AF37),
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white70),
                          onPressed: () => _deleteItem(item.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
