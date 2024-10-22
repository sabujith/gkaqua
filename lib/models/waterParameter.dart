class waterParameterModel {
  int? id;
  String? parameter_code;
  String? parameter_name;
  String? notes;
  String? start_date;
  String? end_date;
  int? unit_id;

  waterParameterModel(
      {required this.id,
      required this.parameter_code,
      required this.parameter_name,
      this.notes,
      this.start_date,
      this.end_date,
      required this.unit_id});

  factory waterParameterModel.fromJson(Map<String, dynamic> json) {
    return waterParameterModel(
        id: json['id'],
        parameter_code: json['parameter_code'],
        parameter_name: json['parameter_name'],
        notes: json['notes'],
        start_date: json['start_date'],
        end_date: json['end_date'],
        unit_id: json['unit_id']);
  }

  toJson() {}
}
