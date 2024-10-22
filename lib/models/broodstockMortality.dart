class BroodstockMortalityModel {
  int? id;
  String date;
  String employee_code;
  String department_id;
  String division_id;
  String tank_id;
  int male_prawn_count;
  int female_prawn_count;
  String? notes;

  BroodstockMortalityModel(
      {this.id,
      required this.date,
      required this.employee_code,
      required this.department_id,
      required this.division_id,
      required this.tank_id,
      required this.male_prawn_count,
      required this.female_prawn_count,
      this.notes});

  factory BroodstockMortalityModel.fromJson(Map<String, dynamic> json) {
    return BroodstockMortalityModel(
        id: json['id'],
        date: json['date'],
        employee_code: json['employee_code'],
        department_id: json['department_id'],
        division_id: json['division_id'],
        tank_id: json['tank_id'],
        male_prawn_count: json['male_prawn_count'],
        female_prawn_count: json['female_prawn_count'],
        notes: json['notes']);
  }
}
