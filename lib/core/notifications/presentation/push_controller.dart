// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:developer' as developer;

import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/notifications/domain/device_token.dart';
import 'package:family_hub/core/notifications/domain/push_diagnostics.dart';
import 'package:family_hub/core/notifications/domain/push_message.dart';
import 'package:family_hub/core/notifications/domain/push_messaging_service.dart';
import 'package:family_hub/core/notifications/domain/usecases/register_device_token.dart';
import 'package:family_hub/core/notifications/domain/usecases/remove_device_token.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:flutter/widgets.dart';

part 'push_controller_operations.dart';

final class PushController with WidgetsBindingObserver {
  // Keep the public named argument API while assigning to private fields.
  PushController({
    required PushMessagingService messaging,
    required RegisterDeviceToken registerDeviceToken,
    required RemoveDeviceToken removeDeviceToken,
    required DeviceInstallationStore installationStore,
    required IdGenerator newId,
    required Clock clock,
    required Flavor flavor,
    required String appVersion,
  }) : _messaging = messaging,
       _registerDeviceToken = registerDeviceToken,
       _removeDeviceToken = removeDeviceToken,
       _installationStore = installationStore,
       _newId = newId,
       _clock = clock,
       _flavor = flavor,
       _appVersion = appVersion;

  final PushMessagingService _messaging;
  final RegisterDeviceToken _registerDeviceToken;
  final RemoveDeviceToken _removeDeviceToken;
  final DeviceInstallationStore _installationStore;
  final IdGenerator _newId;
  final Clock _clock;
  final Flavor _flavor;
  final String _appVersion;
  final StreamController<PushDiagnostics> _diagnosticsChanges =
      StreamController<PushDiagnostics>.broadcast();

  PushDiagnostics _diagnostics = const PushDiagnostics();
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<PushMessage>? _foregroundSubscription;
  DeviceInstallation? _installation;
  String? _uid;
  String? _cleanupUid;
  String _languageCode = 'bn';
  String? _registeredToken;
  String? _lastRegistrationDay;
  Future<DeviceInstallation>? _installationFuture;
  bool _observingLifecycle = false;
  bool _permissionRequested = false;
  bool _disposed = false;

  PushDiagnostics get diagnostics => _diagnostics;

  Stream<PushDiagnostics> get diagnosticsStream async* {
    yield _diagnostics;
    yield* _diagnosticsChanges.stream;
  }

  Future<void> onSessionActive({
    required String uid,
    required String languageCode,
  }) async {
    if (_disposed) return;
    if (_uid != uid) {
      if (_uid != null) {
        final previousUid = _uid!;
        final result = await _unregister(previousUid);
        final failure = result.failureOrNull;
        if (failure != null) {
          _cleanupUid = previousUid;
          _recordFailure(failure);
        } else if (_cleanupUid == previousUid) {
          _cleanupUid = null;
        }
      }
      _uid = uid;
      if (_cleanupUid == uid) _cleanupUid = null;
      _registeredToken = null;
      _languageCode = languageCode;
      _startSubscriptions();
      await _refreshPermission();
      // Ask once per session when the OS still blocks notifications, so they
      // actually reach the Android notification panel.
      await _requestPermissionOnce();
      await _registerCurrentToken();
      return;
    }

    await onLanguageChanged(languageCode);
  }

  Future<void> onLanguageChanged(String languageCode) async {
    if (_uid == null || _languageCode == languageCode) return;
    _languageCode = languageCode;
    await _registerCurrentToken();
  }

  Future<void> onSessionEnded() async {
    final uid = _uid;
    if (uid == null) return;
    final result = await _unregister(uid);
    final failure = result.failureOrNull;
    if (failure != null) {
      _cleanupUid = uid;
      _recordFailure(failure);
    } else if (_cleanupUid == uid) {
      _cleanupUid = null;
    }
    _uid = null;
    _registeredToken = null;
    await _stopSubscriptions();
    _update(
      _diagnostics.copyWith(tokenRegistered: false, clearTokenPrefix: true),
    );
  }

  Future<Result<void>> unregisterForSignOut() async {
    final uid = _uid ?? _cleanupUid;
    final result = uid == null
        ? await _deleteTokenOnly()
        : await _unregister(uid);
    if (result.isSuccess) {
      _uid = null;
      _cleanupUid = null;
      _registeredToken = null;
      await _stopSubscriptions();
      _update(
        _diagnostics.copyWith(tokenRegistered: false, clearTokenPrefix: true),
      );
    }
    return result;
  }

  Future<bool> requestPermission() async {
    try {
      final granted = await _messaging.requestPermission();
      _update(_diagnostics.copyWith(notificationsGranted: granted));
      if (granted && _uid != null) await _registerCurrentToken();
      return granted;
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> onResumed() async {
    final uid = _uid;
    if (uid == null) return;
    final day = _pushDayKey(_clock.nowUtc());
    if (_lastRegistrationDay == day) {
      await _refreshPermission();
      return;
    }
    _lastRegistrationDay = day;
    await _refreshPermission();
    await _registerCurrentToken();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(onResumed());
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _removeLifecycleObserver();
    await _stopSubscriptions();
    await _diagnosticsChanges.close();
  }
}
