class EmployeeModel {
  int? id;
  String employee_code;
  String name;
  String department_id;
  String mobile;
  String? address;
  String? blood_group;
  String document_type;
  String mycad_or_passport_no;
  String? notes;
  String? start_date;
  String? end_date;

  EmployeeModel(
      {this.id,
      required this.employee_code,
      required this.name,
      required this.department_id,
      required this.mobile,
      this.address,
      this.blood_group,
      required this.document_type,
      required this.mycad_or_passport_no,
      this.notes,
      this.start_date,
      this.end_date});

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      employee_code: json['employee_code'],
      name: json['name'],
      department_id: json['department_id'],
      mobile: json['mobile'],
      address: json['address'],
      blood_group: json['blood_group'],
      document_type: json['document_type'],
      mycad_or_passport_no: json['mycad_or_passport_no'],
      notes: json['notes'],
      start_date: json['start_date'],
      end_date: json['end_date'],
    );
  }
}
