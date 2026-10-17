import 'package:interest_schedule/models/schedule_entry.dart';

class CompanyRecord {
  final String id;
  final String companyName;
  final String dateOfInvestment;
  final String tenure;
  final double principal;
  final List<ScheduleEntry> scheduleEntries;

  CompanyRecord({
    required this.id,
    required this.companyName,
    required this.dateOfInvestment,
    required this.tenure,
    required this.principal,
    required this.scheduleEntries,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'dateOfInvestment': dateOfInvestment,
    'tenure': tenure,
    'principal': principal,
    'scheduleEntries': scheduleEntries.map((e) => e.toJson()).toList(),
  };

  factory CompanyRecord.fromJson(Map<String, dynamic> json) => CompanyRecord(
    id: json['id'],
    companyName: json['companyName'],
    dateOfInvestment: json['dateOfInvestment'] ?? json['dn'] ?? '',
    tenure: json['tenure'],
    principal: (json['principal'] ?? json['amount'] as num).toDouble(),
    scheduleEntries: (json['scheduleEntries'] as List<dynamic>?)
        ?.map((e) => ScheduleEntry.fromJson(e))
        .toList() ??
        [],
  );
}