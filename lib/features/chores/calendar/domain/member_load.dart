final class MemberLoad {
  const MemberLoad({required this.memberId, required this.count});

  /// Null is the unassigned bucket.
  final String? memberId;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is MemberLoad && other.memberId == memberId && other.count == count;

  @override
  int get hashCode => Object.hash(memberId, count);
}
