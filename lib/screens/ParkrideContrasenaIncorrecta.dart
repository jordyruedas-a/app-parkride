import 'package:flutter/material.dart';
import 'ParkrideLogin.dart';

class ParkrideContrasenaIncorrecta extends StatelessWidget {
  const ParkrideContrasenaIncorrecta({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParkrideLogin(hasError: true);
  }
}
