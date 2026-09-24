import 'package:flutter/material.dart';

class ParkrideCrearCuenta extends StatefulWidget {
  const ParkrideCrearCuenta({super.key});

  @override
  State<ParkrideCrearCuenta> createState() => _ParkrideCrearCuentaState();
}

class _ParkrideCrearCuentaState extends State<ParkrideCrearCuenta> {
  final _nombreController = TextEditingController(text: "Raúl Jiménez Beltrán");
  final _emailController = TextEditingController(text: "raul.jimenez@corporativo.com");
  final _deptoController = TextEditingController(text: "Tecnología e Innovación");
  final _passController = TextEditingController(text: "12345678");

  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("¡Cuenta creada exitosamente! Bienvenido a ParkRide."),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
    Navigator.pushReplacementNamed(context, '/ParkrideDashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "Crear Cuenta",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Registro exclusivo para personal del parque industrial",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: "Nombre Completo",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Correo Corporativo",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _deptoController,
                        decoration: InputDecoration(
                          labelText: "Departamento",
                          prefixIcon: const Icon(Icons.business_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Crear Cuenta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
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
