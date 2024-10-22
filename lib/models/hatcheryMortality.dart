class HatcheryMortalityModel {
  int? id;
  String date;
  String employee_code;
  int department_id;
  int division_id;
  int tank_id;
  int larvae_count;
  int count_multiplier;
  int total_mortality_count;
  String? notes;

  HatcheryMortalityModel({
    this.id,
    required this.date,
    required this.employee_code,
    required this.department_id,
    required this.division_id,
    required this.tank_id,
    required this.larvae_count,
    required this.count_multiplier,
    required this.total_mortality_count,
    this.notes,
  });

  factory HatcheryMortalityModel.fromJson(Map<String, dynamic> json) {
    return HatcheryMortalityModel(
      id: json['id'],
      date: json['date'],
      employee_code: json['employee_code'],
      department_id: json['department_id'],
      division_id: json['division_id'],
      tank_id: json['tank_id'],
      larvae_count: json['larvae_count'],
      count_multiplier: json['count_multiplier'],
      total_mortality_count: json['total_mortality_count'],
      notes: json['notes'],
    );
  }
}
