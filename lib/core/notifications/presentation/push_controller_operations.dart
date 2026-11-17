part of 'push_controller.dart';

extension _PushControllerOperations on PushController {
  void _startSubscriptions() {
    if (_tokenRefreshSubscription != null) return;
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (token) => unawaited(_registerToken(token, tokenRefreshed: true)),
      onError: (Object error, StackTrace stackTrace) {
        _recordError(error, stackTrace);
      },
    );
    _foregroundSubscription = _messaging.onForegroundMessage.listen(
      (_) =>
          _update(_diagnostics.copyWith(lastReceivedMessage: _clock.nowUtc())),
      onError: (Object error, StackTrace stackTrace) {
        _recordError(error, stackTrace);
      },
    );
    if (!_observingLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
    }
  }

  Future<void> _stopSubscriptions() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundSubscription = null;
    _removeLifecycleObserver();
  }

  void _removeLifecycleObserver() {
    if (!_observingLifecycle) return;
    WidgetsBinding.instance.removeObserver(this);
    _observingLifecycle = false;
  }

  Future<void> _refreshPermission() async {
    try {
      final granted = await _messaging.notificationsGranted();
      _update(_diagnostics.copyWith(notificationsGranted: granted));
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
    }
  }

  Future<void> _requestPermissionOnce() async {
    if (_permissionRequested || _diagnostics.notificationsGranted) return;
    _permissionRequested = true;
    try {
      final granted = await _messaging.requestPermission();
      _update(_diagnostics.copyWith(notificationsGranted: granted));
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
    }
  }

  Future<void> _registerCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        _registeredToken = null;
        _update(
          _diagnostics.copyWith(tokenRegistered: false, clearTokenPrefix: true),
        );
        return;
      }
      await _registerToken(token);
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
    }
  }

  Future<void> _registerToken(
    String token, {
    bool tokenRefreshed = false,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final installation = await _installationForRegistration();
      final now = _clock.nowUtc();
      final result = await _registerDeviceToken(
        uid: uid,
        deviceId: installation.id,
        token: token,
        languageCode: _languageCode,
        appVersion: _appVersion,
        flavor: _flavor.name,
        createdAt: installation.createdAt,
        lastSeenAt: now,
      );
      final failure = result.failureOrNull;
      if (failure != null) {
        _recordFailure(failure);
        return;
      }

      final tokenChanged = _registeredToken != token;
      _registeredToken = token;
      _lastRegistrationDay = _pushDayKey(now);
      _update(
        _diagnostics.copyWith(
          tokenRegistered: true,
          tokenPrefix: token.substring(0, token.length < 6 ? token.length : 6),
          lastTokenRefresh:
              tokenRefreshed ||
                  tokenChanged ||
                  _diagnostics.lastTokenRefresh == null
              ? now
              : _diagnostics.lastTokenRefresh,
          clearLastError: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
    }
  }

  Future<Result<void>> _unregister(String uid) async {
    AppFailure? failure;
    try {
      final installation =
          _installation ??
          await (_installationFuture ?? _installationStore.read());
      if (installation != null) {
        failure = (await _removeDeviceToken(
          uid: uid,
          deviceId: installation.id,
        )).failureOrNull;
      }
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
      failure = Unknown(error);
    }

    final tokenResult = await _deleteTokenOnly();
    failure ??= tokenResult.failureOrNull;
    if (failure != null) return Failure<void>(failure);
    return const Success<void>(null);
  }

  Future<DeviceInstallation> _installationForRegistration() {
    return _installationFuture ??= _installationStore
        .getOrCreate(newId: _newId, nowUtc: _clock.nowUtc())
        .then((installation) {
          _installation = installation;
          return installation;
        });
  }

  Future<Result<void>> _deleteTokenOnly() async {
    try {
      await _messaging.deleteToken();
      _registeredToken = null;
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
      return Failure<void>(Unknown(error));
    }
  }

  void _recordFailure(AppFailure failure) {
    _update(
      _diagnostics.copyWith(
        tokenRegistered: false,
        clearTokenPrefix: true,
        lastError: failure.runtimeType.toString(),
      ),
    );
  }

  void _recordError(Object error, StackTrace stackTrace) {
    final token = _registeredToken;
    final message = token == null
        ? error.toString()
        : error.toString().replaceAll(token, '[redacted]');
    _update(
      _diagnostics.copyWith(
        tokenRegistered: false,
        clearTokenPrefix: true,
        lastError: message.length > 160 ? message.substring(0, 160) : message,
      ),
    );
    developer.log(
      'Push operation failed (${error.runtimeType}).',
      name: 'family_hub.notifications',
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  void _update(PushDiagnostics next) {
    if (_diagnostics == next || _diagnosticsChanges.isClosed) return;
    _diagnostics = next;
    _diagnosticsChanges.add(next);
  }
}

String _pushDayKey(DateTime instant) =>
    instant.toUtc().toIso8601String().substring(0, 10);
