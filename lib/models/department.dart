// lib/models/department.dart

class Department {
  int id;
  String departmentCode;
  String departmentName;
  String? notes;
  String? startDate; // Make it nullable if it's optional
  String? endDate; // Make it nullable if it's optional

  Department({
    required this.id,
    required this.departmentCode,
    required this.departmentName,
    this.notes,
    this.startDate, // Optional field
    this.endDate, // Optional field
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      departmentCode: json['department_code'],
      departmentName: json['department_name'],
      notes: json['notes'] ?? '',
      startDate: json['start_date'], // Ensure the key matches your API response
      endDate: json['end_date'], // Ensure the key matches your API response
    );
  }
}
