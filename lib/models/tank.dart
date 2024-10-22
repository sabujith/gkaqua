class TankModel {
  int? id;
  String tank_code;
  String? tank_name;
  int dept_id;
  int division_id;
  String? notes;
  String? start_date;
  String? end_date;

  TankModel(
      {this.id,
      required this.tank_code,
      this.tank_name,
      required this.dept_id,
      required this.division_id,
      this.notes,
      this.start_date,
      this.end_date});

  factory TankModel.fromJson(Map<String, dynamic> json) {
    return TankModel(
        id: json['id'],
        tank_code: json['tank_code'],
        tank_name: json['tank_name'],
        dept_id: json['dept_id'],
        division_id: json['division_id'],
        notes: json['notes'],
        start_date: json['start_date'],
        end_date: json['end_date']);
  }
}
