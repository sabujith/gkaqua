import 'package:flutter/material.dart';
import 'dart:math';

class BroodingtanksScreen extends StatefulWidget {
  const BroodingtanksScreen({super.key});

  @override
  State<BroodingtanksScreen> createState() => _BroodingtanksScreenState();
}

class _BroodingtanksScreenState extends State<BroodingtanksScreen> {
  // List of tanks with their names and status
  List<Map<String, String>> TanksDetails = [
    {"TankName": "T1", "TankStatus": "Empty"},
    {"TankName": "T2", "TankStatus": "Mating"},
    {"TankName": "T3", "TankStatus": "Resting"},
    {"TankName": "T4", "TankStatus": "Mating"},
    {"TankName": "T5", "TankStatus": "Empty"},
    {"TankName": "T6", "TankStatus": "Mating"},
    {"TankName": "T7", "TankStatus": "Empty"},
    {"TankName": "T8", "TankStatus": "Mating"},
    {"TankName": "T9", "TankStatus": "Mating"},
    {"TankName": "T10", "TankStatus": "Empty"},
    {"TankName": "T11", "TankStatus": "Mating"},
    {"TankName": "T12", "TankStatus": "Mating"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        shadowColor: Colors.blue,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Brooding Tanks',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          // Create a grid with 2 columns
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 8.0, // Space between columns
            mainAxisSpacing: 8.0, // Space between rows
            childAspectRatio: 2, // Aspect ratio of each item (width / height)
          ),
          itemCount: TanksDetails.length, // Number of items
          itemBuilder: (context, index) {
            var tank = TanksDetails[index];
            return WaveAnimation(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.blue, // Background color of each tank card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tank["TankName"]!, // Tank Name
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 0, 53, 132),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tank["TankStatus"]!, // Tank Status
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WaveAnimation extends StatefulWidget {
  final Widget child;

  const WaveAnimation({Key? key, required this.child}) : super(key: key);

  @override
  _WaveAnimationState createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipPath(
          clipper: WaveClipper(_animation.value),
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double progress;

  WaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double waveHeight = 5 * sin(progress * 2 * pi);
    double waveStartHeight = size.height * 0.10; // 25% of the height

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, waveStartHeight + waveHeight);
    path.lineTo(0, waveStartHeight + waveHeight);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
