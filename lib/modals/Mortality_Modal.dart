import 'package:flutter/material.dart';

class MortalityModal extends StatefulWidget {
  const MortalityModal({super.key});

  @override
  State<MortalityModal> createState() => _MortalityModalState();
}

class _MortalityModalState extends State<MortalityModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to retrieve user input
  final TextEditingController _maleMortalityController =
      TextEditingController();
  final TextEditingController _femaleMortalityController =
      TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9, // 90% height
          ),
          child: Container(
            height: 600,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Update Mortality Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Male Prawns Mortality Number Input
                  TextFormField(
                    controller: _maleMortalityController,
                    keyboardType:
                        TextInputType.number, // Ensures only number input
                    decoration: const InputDecoration(
                      labelText: 'Male Prawns Mortality',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of male prawn mortalities';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Female Prawns Mortality Number Input
                  TextFormField(
                    controller: _femaleMortalityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Female Prawns Mortality',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of female prawn mortalities';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Reason Notes Text Area
                  TextFormField(
                    controller: _reasonController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4, // Text area
                    decoration: const InputDecoration(
                      labelText: 'Reason for Mortality',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a reason for mortality';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue.withOpacity(0.8), // Add transparency
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Process data if valid
                        Navigator.of(context)
                            .pop(); // Close the modal after processing
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _maleMortalityController.dispose();
    _femaleMortalityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}

void showMortalityModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Full screen modal
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false, // Allow scrolling when content exceeds the height
        builder: (_, controller) => MortalityModal(),
      );
    },
  );
}
