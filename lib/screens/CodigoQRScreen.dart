import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/supabase_service.dart';

class CodigoQRScreen extends StatefulWidget {
  const CodigoQRScreen({super.key});

  @override
  State<CodigoQRScreen> createState() => _CodigoQRScreenState();
}

class _CodigoQRScreenState extends State<CodigoQRScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;
  DateTime? _lastScanAt;
  TicketValidationResult? _lastValidation;
  String? _lastScannedCode;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processScannedCode(String rawValue) async {
    final cleanedValue = rawValue.trim();
    if (cleanedValue.isEmpty || _isProcessing) return;

    final now = DateTime.now();
    if (_lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(milliseconds: 1200)) {
      return;
    }

    _lastScanAt = now;
    _lastScannedCode = cleanedValue;
    _isProcessing = true;
    setState(() {});

    await _scannerController.stop();

    final validation = await SupabaseService().validateTicketCode(cleanedValue);

    if (!mounted) return;

    if (validation.isValid) {
      await SupabaseService().markTicketAsUsed(cleanedValue);
    }

    setState(() {
      _lastValidation = validation;
      _isProcessing = false;
    });

    await _showValidationResult(validation);
  }

  Future<void> _showValidationResult(TicketValidationResult result) async {
    final isSuccess = result.isValid;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final accentColor =
            isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.verified_user_rounded
                    : Icons.error_outline_rounded,
                color: accentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.passengerName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Pasajero: ${result.passengerName!}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
              const SizedBox(height: 8),
              Text(result.message),
              if (isSuccess) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF22C55E)),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'Acceso autorizado. Puede abordar el vehículo.')),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeScanning();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resumeScanning() async {
    if (!mounted) return;
    setState(() {
      _lastValidation = null;
      _lastScannedCode = null;
      _isProcessing = false;
    });
    await _scannerController.start();
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
        title: const Text(
          'Escaneo QR de Pasajero',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final value = barcode.rawValue;
                    if (value != null && value.isNotEmpty) {
                      _processScannedCode(value);
                      break;
                    }
                  }
                },
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_rounded,
                              size: 54, color: Colors.white70),
                          const SizedBox(height: 12),
                          const Text(
                            'No se pudo acceder a la cámara',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Revisa los permisos de cámara en Android o iOS y vuelve a intentar.',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _resumeScanning,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isProcessing
                            ? 'Validando boleto...'
                            : 'Apunta la cámara al QR del pasajero',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_lastValidation != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _lastValidation!.isValid
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _lastValidation!.title,
                              style: TextStyle(
                                color: _lastValidation!.isValid
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF991B1B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _lastValidation!.message,
                              style: TextStyle(
                                color: _lastValidation!.isValid
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                            if (_lastScannedCode != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Código: $_lastScannedCode",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _lastValidation!.isValid
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _resumeScanning,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reanudar escaneo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
