import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';

/// Runs a Firestore call and converts failures into [AppFailure]; nothing
/// thrown by Firestore crosses the data layer.
Future<Result<T>> guardFirestore<T>(Future<T> Function() call) async {
  try {
    return Success<T>(await call().timeout(const Duration(seconds: 30)));
  } on FirebaseException catch (e) {
    return Failure<T>(mapFirestoreCode(e.code));
  } on TimeoutException {
    return Failure<T>(const Network());
  } on Object catch (e) {
    return Failure<T>(Unknown(e));
  }
}

/// Converts a stream's failures into [AppFailure], so a screen can show a
/// specific message instead of the generic one. Values pass through untouched.
Stream<T> guardStream<T>(Stream<T> source) => source.handleError(
  (Object error) => throw switch (error) {
    AppFailure() => error,
    FirebaseException(:final code) => mapFirestoreCode(code),
    TimeoutException() => const Network(),
    _ => Unknown(error),
  },
);

/// Firestore error code -> failure.
AppFailure mapFirestoreCode(String code) => switch (code) {
  'permission-denied' || 'unauthenticated' => const PermissionDenied(),
  'not-found' => const NotFound(),
  'already-exists' || 'aborted' => const Conflict(),
  'unavailable' || 'deadline-exceeded' || 'cancelled' => const Network(),
  _ => Unknown(code),
};

/// Checks, with a cheap server-only read, that Firestore is reachable.
typedef ServerProbe = Future<bool> Function();

/// Probe used by administrative writes: reads `users/{uid}` from the server.
/// A permission or not-found answer still proves the server is reachable.
ServerProbe serverProbeFor(
  FirebaseFirestore db,
  String uid, {
  Duration timeout = const Duration(seconds: 8),
}) => () async {
  try {
    await db
        .doc('users/$uid')
        .get(const GetOptions(source: Source.server))
        .timeout(timeout);
    return true;
  } on FirebaseException catch (e) {
    return e.code == 'permission-denied' || e.code == 'not-found';
  } on TimeoutException {
    return false;
  } on Object {
    return false;
  }
};

/// Runs a Firestore WRITE (rule 15 / 16).
///
/// * [probe] != null means the write REQUIRES the server (onboarding and
///   administrative actions): if the probe fails the result is `Network` and
///   nothing is written.
/// * Otherwise, or after a successful probe, the commit starts.  A commit only
///   completes once the server acknowledges it, so if it has not completed after
///   [ackWait] the write is treated as QUEUED: the SDK keeps it and syncs later,
///   so this returns success and keeps listening in the background.
Future<Result<void>> guardWrite(
  Future<void> Function() commit, {
  ServerProbe? probe,
  Duration ackWait = const Duration(seconds: 8),
}) async {
  try {
    if (probe != null && !await probe()) {
      return const Failure<void>(Network());
    }
    final pending = commit();
    try {
      await pending.timeout(ackWait);
    } on TimeoutException {
      unawaited(
        pending.then<void>(
          (_) {},
          onError: (Object e, StackTrace st) => developer.log(
            'Queued write was rejected by the server',
            name: 'family_hub',
            error: e,
            stackTrace: st,
            level: 1000,
          ),
        ),
      );
    }
    return const Success<void>(null);
  } on FirebaseException catch (e) {
    return Failure<void>(mapFirestoreCode(e.code));
  } on Object catch (e) {
    return Failure<void>(Unknown(e));
  }
}
