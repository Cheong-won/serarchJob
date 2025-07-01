class JobResult {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String workSchedule;
  final String workPeriod;
  final String description;
  final String url;
  final DateTime? postedDate;
  final String timeAgoText;

  JobResult({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.workSchedule,
    required this.workPeriod,
    required this.description,
    required this.url,
    this.postedDate,
    this.timeAgoText = '',
  });

  factory JobResult.fromJson(Map<String, dynamic> json) {
    return JobResult(
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      workSchedule: json['workSchedule'] ?? '',
      workPeriod: json['workPeriod'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      postedDate: json['postedDate'] != null 
          ? DateTime.tryParse(json['postedDate']) 
          : null,
      timeAgoText: json['timeAgoText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'workSchedule': workSchedule,
      'workPeriod': workPeriod,
      'description': description,
      'url': url,
      'postedDate': postedDate?.toIso8601String(),
      'timeAgoText': timeAgoText,
    };
  }

  @override
  String toString() {
    return 'JobResult(title: $title, company: $company, location: $location)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobResult &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          company == other.company &&
          location == other.location;

  @override
  int get hashCode => Object.hash(title, company, location);
}