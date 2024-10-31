class waterQualityModel {
  int? id;
  String? check_date;
  String? employee_code;
  int? department_id;
  int? division_id;
  int? tank_id;
  int? water_parameter_id;
  num? input_value;
  String? notes;

  waterQualityModel(
      {this.id,
      required this.check_date,
      required this.employee_code,
      required this.department_id,
      required this.division_id,
      required this.tank_id,
      required this.water_parameter_id,
      required this.input_value,
      this.notes});

  factory waterQualityModel.fromJson(Map<String, dynamic> json) {
    return waterQualityModel(
      id: json['id'],
      check_date: json['check_date'],
      employee_code: json['employee_code'],
      department_id: json['department_id'],
      division_id: json['division_id'],
      tank_id: json['tank_id'],
      water_parameter_id: json['water_parameter_id'],
      input_value: json['input_value'],
      notes: json['notes']
    );
  }

  toJson() {}
}
