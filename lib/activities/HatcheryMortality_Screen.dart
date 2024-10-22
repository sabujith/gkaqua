import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HatcheryMortalityScreen extends StatefulWidget {
  const HatcheryMortalityScreen({super.key});

  @override
  State<HatcheryMortalityScreen> createState() =>
      _HatcheryMortalityScreenState();
}

class _HatcheryMortalityScreenState extends State<HatcheryMortalityScreen> {
  final _formKey = GlobalKey<FormState>();

  String? userId;
  DateTime? selectedDate;
  static const selectedDepartment = "Hatchery";
  String? selectedDivision;
  String? selectedTankCode;
  String? SelectedPrawnType;
  double? prawnCount;
  double? countMultiplier;
  String? totalMortalityCount;
  String? notes;

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      getUser(),
      getDivisions(),
      getTankCodes(),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  //fn to get user details
  Future<void> getUser() async {
    setState(() {
      userId = "user123";
    });
  }

  //fn to get divisions
  Future<List<String>> getDivisions() async {
    await Future.delayed(Duration(milliseconds: 100));
    return ['Div1', 'Div2', 'Div3', 'Div4'];
  }

  //fn to get tank codes
  Future<List<String>> getTankCodes() async {
    await Future.delayed(Duration(milliseconds: 100));
    return ['Tank1', 'Tank2', 'Tank3', 'Tank4'];
  }

  //fn to select date
  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2121),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  //fn to multiply the prawn count according to spoon
  void calculateTotalMortality() {
    if (prawnCount != null && countMultiplier != null) {
      setState(() {
        double result = prawnCount! * countMultiplier!;
        totalMortalityCount = result.toString();
      });
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
          'Activity/Hatchery Mortality',
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'User Id : ${userId!}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          selectDate();
                        },
                        child: Text(
                          selectedDate == null
                              ? "Select Date"
                              : DateFormat('dd-MM-yyyy').format(selectedDate!),
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Department",
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedDepartment,
                        style: TextStyle(color: Colors.blue),
                        enabled: false,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: FutureBuilder<List<String>>(
                                  future: getDivisions(),
                                  builder: (context, snapshot) {
                                    return DropdownButtonFormField<String>(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please select Division";
                                          }
                                          return null;
                                        },
                                        value: selectedDivision,
                                        decoration: const InputDecoration(
                                          labelText: "Division",
                                          border: OutlineInputBorder(),
                                        ),
                                        items: snapshot.data
                                            ?.map((String Division) {
                                          return DropdownMenuItem<String>(
                                            value: Division,
                                            child: Text(Division),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedDivision = newValue;
                                          });
                                        });
                                  })),
                          SizedBox(width: 10),
                          Expanded(
                            child: FutureBuilder<List<String>>(
                                future: getTankCodes(),
                                builder: (context, snapshot) {
                                  return DropdownButtonFormField<String>(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please select a Tank";
                                        }
                                        return null;
                                      },
                                      value: selectedTankCode,
                                      decoration: const InputDecoration(
                                          labelText: "Tank Code",
                                          border: OutlineInputBorder()),
                                      items:
                                          snapshot.data?.map((String tankCode) {
                                        return DropdownMenuItem<String>(
                                          value: tankCode,
                                          child: Text(tankCode),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedTankCode = newValue;
                                        });
                                      });
                                }),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField(
                        items:
                            ["Larvae", "Post Larvae"].map((String prawnType) {
                          return DropdownMenuItem(
                              value: prawnType, child: Text(prawnType));
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            SelectedPrawnType = newValue;
                          });
                        },
                        value: SelectedPrawnType,
                        decoration: const InputDecoration(
                            labelText: "Prawn Type",
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Select Prawn Type";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text("Calculate Prawn Count",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        decoration: const InputDecoration(
                                            labelText: "Prawn Count",
                                            border: OutlineInputBorder()),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          prawnCount = double.parse(value);
                                        },
                                      ),
                                      Text('(Count in Spoons)')
                                    ],
                                  ),
                                )),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          decoration: const InputDecoration(
                                              labelText: "Count Multiplier",
                                              border: OutlineInputBorder()),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            countMultiplier =
                                                double.parse(value);
                                          },
                                        ),
                                        Text("(Count per Spoon)")
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.green, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                calculateTotalMortality();
                              },
                              child: const Text(
                                "Calculate",
                                style: TextStyle(color: Colors.green),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Total Moratality Count",
                            border: OutlineInputBorder()),
                        initialValue: totalMortalityCount,
                        // enabled: false,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "This field can't be empty";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Notes", border: OutlineInputBorder()),
                        onChanged: (value) {
                          setState(() {
                            notes = value;
                          });
                        },
                        maxLines: 4,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () {
                          FormSubmit();
                        },
                        child: const Text("Submit",
                            style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void FormSubmit() {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Success \n \n $selectedDate \n $selectedDepartment \n $selectedDivision \n $selectedTankCode \n $SelectedPrawnType \n $totalMortalityCount"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        selectedDate = null;
        selectedDivision = null;
        selectedTankCode = null;
        SelectedPrawnType = null;
        totalMortalityCount = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Fill out all the fields'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
    }
  }
}
