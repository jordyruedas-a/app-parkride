import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/parkride_state.dart';
import '../widgets/app_logo.dart';

class ParkrideCrearCuenta extends StatefulWidget {
  const ParkrideCrearCuenta({super.key});

  @override
  State<ParkrideCrearCuenta> createState() => _ParkrideCrearCuentaState();
}

class _ParkrideCrearCuentaState extends State<ParkrideCrearCuenta> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _numEmpleadoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _empresaController = TextEditingController();
  final _vehiculoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String _selectedRol = 'Pasajero';
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _departamentoController.dispose();
    _numEmpleadoController.dispose();
    _telefonoController.dispose();
    _empresaController.dispose();
    _vehiculoController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre =
        '${_nombreController.text.trim()} ${_apellidoController.text.trim()}';
    final email = _emailController.text.trim();
    final departamento = _departamentoController.text.trim();
    final empresa = _empresaController.text.trim();
    final telefono = _telefonoController.text.trim();
    final numEmpleado = _numEmpleadoController.text.trim();
    final vehicleInfo = _vehiculoController.text.trim();
    final pass = _passController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ParkRideState().registerUser(
        nombre: nombre,
        email: email,
        password: pass,
        rol: _selectedRol,
        empresa: empresa.isNotEmpty ? empresa : departamento,
        telefono: telefono,
        departamento: departamento,
        numEmpleado: numEmpleado,
        vehicleInfo: (_selectedRol.toLowerCase().contains('ruta') ||
                _selectedRol.toLowerCase().contains('chofer') ||
                _selectedRol.toLowerCase().contains('conductor'))
            ? vehicleInfo
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Cuenta creada exitosamente! Bienvenido a ParkRide."),
          backgroundColor: Color(0xFF22C55E),
        ),
      );

      if (_selectedRol.toLowerCase().contains('supervisor') ||
          _selectedRol.toLowerCase().contains('admin') ||
          _selectedRol.toLowerCase().contains('administrador')) {
        Navigator.pushReplacementNamed(context, '/SupervisorDashboard');
      } else if (_selectedRol.toLowerCase().contains('ruta') ||
          _selectedRol.toLowerCase().contains('conductor') ||
          _selectedRol.toLowerCase().contains('chofer')) {
        Navigator.pushReplacementNamed(context, '/ChoferRuta');
      } else {
        Navigator.pushReplacementNamed(context, '/ParkrideDashboard');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo crear la cuenta: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const AppLogo(size: 72, borderRadius: 18, showBorder: true),
                const SizedBox(height: 12),
                const Text(
                  "Crear Cuenta",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Plataforma de Movilidad Corporativa",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Rol Selector
                        const Text(
                          "Tipo de Cuenta",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                                child: _buildRoleChip(
                                    'Pasajero', Icons.person_rounded)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildRoleChip('Chofer de Ruta',
                                    Icons.directions_bus_rounded)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildRoleChip('Administrador',
                                    Icons.admin_panel_settings_rounded)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_selectedRol.toLowerCase().contains('ruta') ||
                            _selectedRol.toLowerCase().contains('chofer') ||
                            _selectedRol
                                .toLowerCase()
                                .contains('conductor')) ...[
                          _buildField(
                            controller: _vehiculoController,
                            label: "Marca, modelo y placa del auto *",
                            icon: Icons.local_shipping_outlined,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Ingresa la marca, modelo y placa del auto";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Nombre y Apellido
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: _nombreController,
                                label: "Nombre(s) *",
                                icon: Icons.person_outline,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Requerido"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: _apellidoController,
                                label: "Apellido(s) *",
                                icon: Icons.person_outline,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Requerido"
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Número de Empleado
                        _buildField(
                          controller: _numEmpleadoController,
                          label: "Número de Empleado *",
                          icon: Icons.badge_outlined,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Número de empleado requerido"
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Correo
                        _buildField(
                          controller: _emailController,
                          label: "Correo Corporativo *",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Correo requerido";
                            if (!v.contains('@')) return "Correo inválido";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Departamento
                        _buildField(
                          controller: _departamentoController,
                          label: "Departamento *",
                          icon: Icons.corporate_fare_outlined,
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Departamento requerido"
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Empresa (opcional)
                        _buildField(
                          controller: _empresaController,
                          label: "Empresa (opcional)",
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 14),

                        // Teléfono (opcional)
                        _buildField(
                          controller: _telefonoController,
                          label: "Teléfono de Contacto (opcional)",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),

                        // Contraseña
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscurePass,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: null,
                          decoration: _fieldDecoration(
                            label: "Contraseña *",
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: const Color(0xFF64748B),
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Contraseña requerida";
                            if (v.length < 8) return "Mínimo 8 caracteres";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Confirmar contraseña
                        TextFormField(
                          controller: _confirmPassController,
                          obscureText: _obscureConfirmPass,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: null,
                          decoration: _fieldDecoration(
                            label: "Confirmar Contraseña *",
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: const Color(0xFF64748B),
                              ),
                              onPressed: () => setState(() =>
                                  _obscureConfirmPass = !_obscureConfirmPass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Confirma tu contraseña";
                            if (v != _passController.text)
                              return "Las contraseñas no coinciden";
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    "Crear Cuenta",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String rol, IconData icon) {
    final isSelected = _selectedRol == rol;
    return GestureDetector(
      onTap: () => setState(() => _selectedRol = rol),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF22C55E).withValues(alpha: 0.12)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF94A3B8),
                size: 22),
            const SizedBox(height: 4),
            Text(
              rol,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF15803D)
                    : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: null,
      decoration: _fieldDecoration(label: label, icon: icon),
      validator: validator,
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
    );
  }
}
