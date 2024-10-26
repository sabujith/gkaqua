import 'package:flutter/material.dart';

class TestingScreen extends StatefulWidget {
  TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _input1Controller = TextEditingController();

  final _input2Controller = TextEditingController();

  bool _isInput1Empty = true;

  bool _isInput2Empty = true;

  // Method to validate only Input 1
  Future<void> _testInput1() async {
    // This will trigger validation only for Input 1
    if (_input1Controller.text.isEmpty || _input1Controller.text == null) {
      setState(() {
        _isInput1Empty = true;
      });
    }
  }

  // Method to validate both inputs
  Future<void> _testInputAll() async {
    // This will trigger validation for both inputs
    if (_formKey.currentState != null) {
      bool isValid = _formKey.currentState!.validate();
      if (isValid) {
        // Both inputs are valid
        print("Both inputs are valid");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Testing Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Testing Screen'),
              SizedBox(height: 20),
              TextFormField(
                controller: _input1Controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Input 1',
                ),
                validator: (_) {
                  if (_isInput1Empty) {
                    return 'Please enter something in Input 1';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testInput1,
                child: const Text('Test Input 1'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _input2Controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Input 2',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter something in Input 2';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testInputAll,
                child: const Text('Test all'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
