class UnitModel {
  int id;
  String unit_code;
  String unit_name;
  String? notes;
  String? start_date;
  String? end_date;

  UnitModel(
      {required this.id,
      required this.unit_code,
      required this.unit_name,
      this.notes,
      this.start_date,
      this.end_date});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
        id: json['id'],
        unit_code: json['unit_code'],
        unit_name: json['unit_name'],
        notes: json['notes'],
        start_date: json['start_date'],
        end_date: json['end_date']);
  }

  toJson() {}
}
