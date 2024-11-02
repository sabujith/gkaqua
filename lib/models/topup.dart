class TopupModel {
  int? id;
  String date;
  String employee_code;
  int department_id;
  int division_id;
  int tank_id;
  String week_start;
  String week_end;
  int male_prawn_mortality_count;
  int female_prawn_mortality_count;
  int male_prawn_topup_count;
  int female_prawn_topup_count;
  String? notes;

  TopupModel({
    this.id,
    required this.date,
    required this.employee_code,
    required this.department_id,
    required this.division_id,
    required this.tank_id,
    required this.week_start,
    required this.week_end,
    required this.male_prawn_mortality_count,
    required this.female_prawn_mortality_count,
    required this.male_prawn_topup_count,
    required this.female_prawn_topup_count,
    this.notes,
  });

  factory TopupModel.fromJson(Map<String, dynamic> json) {
    return TopupModel(
      id: json['id'],
      date: json['date'],
      employee_code: json['employee_code'],
      department_id: json['department_id'],
      division_id: json['division_id'],
      tank_id: json['tank_id'],
      week_start: json['week_start'],
      week_end: json['week_end'],
      male_prawn_mortality_count: json['male_prawn_mortality_count'],
      female_prawn_mortality_count: json['female_prawn_mortality_count'],
      male_prawn_topup_count: json['male_prawn_topup_count'],
      female_prawn_topup_count: json['female_prawn_topup_count'],
      notes: json['notes'],
    );
  }
}
