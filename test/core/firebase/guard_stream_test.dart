import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Object?> _errorOf(Stream<int> stream) => stream.toList().then<Object?>(
  (_) => null,
  onError: (Object error) => error,
);

void main() {
  group('guardStream', () {
    test('passes values through untouched', () async {
      final values = await guardStream(Stream<int>.value(7)).toList();
      expect(values, <int>[7]);
    });

    test('maps a Firestore permission error to PermissionDenied', () async {
      final error = await _errorOf(
        guardStream(
          Stream<int>.error(
            FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
            ),
          ),
        ),
      );
      expect(error, isA<PermissionDenied>());
    });

    test('maps an unknown error to Unknown', () async {
      final error = await _errorOf(guardStream(Stream<int>.error('boom')));
      expect(error, isA<Unknown>());
    });

    test('keeps an AppFailure unchanged', () async {
      final error = await _errorOf(
        guardStream(Stream<int>.error(const Network())),
      );
      expect(error, isA<Network>());
    });
  });
}
