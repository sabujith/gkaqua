import 'package:flutter/material.dart';

class WaterQuality extends StatelessWidget {
  const WaterQuality({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaterqualityActivityScreen(),
    );
  }
}

class WaterqualityActivityScreen extends StatefulWidget {
  const WaterqualityActivityScreen({super.key});

  @override
  State<WaterqualityActivityScreen> createState() => _WaterqualityActivityScreenState();
}

class _WaterqualityActivityScreenState extends State<WaterqualityActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}