class HealthInsight {
  HealthInsight({
    required this.summary,
    required this.possibleCauses,
    required this.whatThisMeans,
    required this.whatToDo,
    required this.whenToConsult,
    required this.disclaimer,
  });

  final String summary;
  final List<String> possibleCauses;
  final String whatThisMeans;
  final String whatToDo;
  final String whenToConsult;
  final String disclaimer;
}
