import 'package:flutter/material.dart';
import '../services/parkride_state.dart';

class ParkrideLogin extends StatefulWidget {
  final bool hasError;
  const ParkrideLogin({super.key, this.hasError = false});

  @override
  State<ParkrideLogin> createState() => _ParkrideLoginState();
}

class _ParkrideLoginState extends State<ParkrideLogin> {
  final _emailController = TextEditingController(text: "raul.jimenez@corporativo.com");
  final _passwordController = TextEditingController(text: "12345678");
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _showError = widget.hasError;
  }

  void _login() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    if (pass == "error" || pass == "123") {
      setState(() => _showError = true);
      return;
    }

    ParkRideState().loginUser(email, pass);
    Navigator.pushReplacementNamed(context, '/ParkrideDashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.electric_car_rounded,
                    size: 64,
                    color: Color(0xFF22C55E),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  "PARKRIDE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "Sistema de Movilidad Corporativa UANL / FIME",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // Login Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Iniciar Sesión",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        "Ingresa tu cuenta corporativa o número de nómina",
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),

                      const SizedBox(height: 20),

                      if (_showError) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Contraseña incorrecta o usuario no encontrado.",
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email input
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Correo Corporativo / Nómina",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password input
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Contacta al departamento de TI de la empresa para reestablecer.")),
                            );
                          },
                          child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Color(0xFF22C55E))),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Iniciar Sesión",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿No tienes cuenta? ", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/ParkrideCrearCuenta'),
                            child: const Text(
                              "Crear cuenta",
                              style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
