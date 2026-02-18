/// Single notification item for the Notifications screen.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.dateGroup,
    required this.iconId,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final String timeAgo;
  /// 'today' or 'yesterday'
  final String dateGroup;
  /// 0=lab, 1=person, 2=calendar, 3=lightbulb
  final int iconId;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      description: description,
      timeAgo: timeAgo,
      dateGroup: dateGroup,
      iconId: iconId,
      isRead: isRead ?? this.isRead,
    );
  }
}
