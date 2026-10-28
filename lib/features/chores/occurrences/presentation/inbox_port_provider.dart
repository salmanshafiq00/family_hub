import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The inbox port the chore actions write through (P3-14).
///
/// It is a no-op until P3-26 ships the real inbox, so a completion, a reopen or
/// a reassignment never has to know whether the inbox exists yet. P3-26
/// overrides this provider in `bootstrap.dart`; a test overrides it with a
/// recording fake to assert the row a flow WOULD write.
final inboxPortProvider = Provider<InboxPort>((ref) => const NoopInboxPort());
