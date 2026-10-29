import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class ReportesESGScreen extends StatelessWidget {
  const ReportesESGScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Panel de Reportes ESG",
          style:
              TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary ESG Cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco_rounded,
                            color: Color(0xFF22C55E), size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Métricas de Sostenibilidad Corporate ESG",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildESGStat("6.8 Kg", "CO₂ Evitado este mes"),
                        _buildESGStat("18", "Viajes compartidos"),
                        _buildESGStat("94%", "Eficiencia de rutas"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Demanda por rutas de movilidad aeroportuaria",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),

              _buildBarChartRow(
                  "Santa Catarina → Aeropuerto", 0.88, "48 viajes"),
              _buildBarChartRow("Centro → Aeropuerto", 0.92, "57 viajes"),
              _buildBarChartRow("Apodaca → Aeropuerto", 0.66, "34 viajes"),
              _buildBarChartRow("San Jerónimo → Aeropuerto", 0.48, "27 viajes"),
              _buildBarChartRow(
                  "Rutas especiales de acceso", 0.32, "18 viajes"),

              const SizedBox(height: 24),

              const Text(
                "Distribución por tipo de transporte",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildMobilityTypeRow(
                        "Camión", "41%", const Color(0xFF22C55E)),
                    const Divider(),
                    _buildMobilityTypeRow(
                        "Van corporativa", "37%", const Color(0xFF3B82F6)),
                    const Divider(),
                    _buildMobilityTypeRow(
                        "Carpooling", "22%", const Color(0xFFF59E0B)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 3),
    );
  }

  static Widget _buildESGStat(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  static Widget _buildBarChartRow(String label, double ratio, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              Text(count,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22C55E))),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio,
            backgroundColor: const Color(0xFFE2E8F0),
            color: const Color(0xFF22C55E),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  static Widget _buildMobilityTypeRow(
      String title, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
          Text(percent,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
