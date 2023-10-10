class UserReport {
  UserReport({
    required this.id,
    required this.userId,
    required this.reason,
  });

  String id;
  String userId;
  String reason;
}

class UserReportDB {
  final List<UserReport> _userReports = [
    UserReport(
      id: '0',
      userId: '0',
      reason: 'Is not a real person',
    ),
  ];

  UserReport getById(String id) {
    return _userReports.firstWhere((ur) => ur.id == id);
  }

  List<UserReport> getUserReports(String userId) {
    return _userReports.where((ur) => ur.userId == userId).toList();
  }
}

UserReportDB userReportDB = UserReportDB();
