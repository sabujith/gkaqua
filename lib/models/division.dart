class DivisionModel {
  int? id;
  String division_code;
  String division_name;
  int department_id;
  String? notes;
  String? start_date;
  String? end_date;

  DivisionModel({
    this.id,
    required this.division_code,
    required this.division_name,
    required this.department_id,
    this.notes,
    this.start_date,
    this.end_date,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) {
    return DivisionModel(
      id: json['id'],
      division_code: json['division_code'],
      division_name: json['division_name'],
      department_id: json['department_id'],
      notes: json['notes'],
      start_date: json['start_date'],
      end_date: json['end_date'],
    );
  }
}
