import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkpoint3_550983_552041/screens/login/login_screen.dart';
import 'package:checkpoint3_550983_552041/screens/home/home_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  final List<Map<String, dynamic>> pages = [
    {
      "title": "Golden Vault",
      "subtitle": "Guarde suas senhas com máxima proteção.",
      "lottie": "assets/lottie/intro.json"
    },
    {
      "title": "Acesso Exclusivo",
      "subtitle": "Controle absoluto com criptografia de ponta.",
      "lottie": "assets/lottie/login.json"
    },
    {
      "title": "Cofre Premium",
      "subtitle": "O lugar mais seguro para guardar o que for preciso.",
      "lottie": "assets/lottie/home.json"
    },
  ];

  void _finishIntro() async {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => LoginScreen()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() => _currentPage = value);
                },
                itemCount: pages.length,
                itemBuilder: (_, index) {
                  final page = pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(page["lottie"], width: 220),
                      const SizedBox(height: 32),
                      Text(
                        page["title"],
                        style: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page["subtitle"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text("Voltar",
                              style: TextStyle(color: Color(0xFFD4AF37))),
                        )
                      : const SizedBox(width: 72),

                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFFD4AF37)
                              : Colors.white30,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      if (_currentPage == pages.length - 1) {
                        _finishIntro();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == pages.length - 1
                          ? "Concluir"
                          : "Avançar",
                      style: const TextStyle(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ],
              ),
            ),

            if (_currentPage == pages.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _dontShowAgain,
                      activeColor: const Color(0xFFD4AF37),
                      onChanged: (value) =>
                          setState(() => _dontShowAgain = value!),
                    ),
                    const Text(
                      "Não mostrar novamente",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}