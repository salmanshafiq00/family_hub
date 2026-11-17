final class PushMessage {
  PushMessage({this.title, this.body, required Map<String, String> data})
    : data = Map<String, String>.unmodifiable(data);

  final String? title;
  final String? body;
  final Map<String, String> data;

  String? get inboxId => data['inboxId'];

  String? get route {
    final configuredRoute = data['route'];
    final id = inboxId;
    if (id == null || id.isEmpty) return configuredRoute;
    if (configuredRoute == null ||
        configuredRoute.isEmpty ||
        configuredRoute == '/inbox') {
      return '/inbox/${Uri.encodeComponent(id)}';
    }
    return configuredRoute;
  }

  @override
  bool operator ==(Object other) =>
      other is PushMessage &&
      other.title == title &&
      other.body == body &&
      other.data.length == data.length &&
      data.entries.every((entry) => other.data[entry.key] == entry.value);

  @override
  int get hashCode => Object.hash(
    title,
    body,
    Object.hashAllUnordered(
      data.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}
