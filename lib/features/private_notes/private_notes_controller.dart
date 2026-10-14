import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateNotesState {
  const PrivateNotesState({
    this.hasPassword = false,
    this.unlockedUntil,
  });

  final bool hasPassword;
  final DateTime? unlockedUntil;

  bool get isUnlocked {
    final until = unlockedUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  PrivateNotesState copyWith({bool? hasPassword, DateTime? unlockedUntil, bool clearUnlock = false}) {
    return PrivateNotesState(
      hasPassword: hasPassword ?? this.hasPassword,
      unlockedUntil: clearUnlock ? null : (unlockedUntil ?? this.unlockedUntil),
    );
  }
}

class PrivateNotesController extends Notifier<PrivateNotesState> {
  static const String _passwordKey = 'private.notes.passwordHash';
  static const Duration sessionTtl = Duration(minutes: 5);

  @override
  PrivateNotesState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return PrivateNotesState(hasPassword: prefs.getString(_passwordKey) != null);
  }

  Future<bool> verify(String input) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_passwordKey);
    if (stored == null) return false;
    final ok = _hash(input) == stored;
    if (ok) _markUnlocked();
    return ok;
  }

  Future<void> setPassword(String newPassword) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_passwordKey, _hash(newPassword));
    _markUnlocked();
    state = state.copyWith(hasPassword: true);
  }

  Future<bool> changePassword({
    required String current,
    required String next,
  }) async {
    final ok = await verify(current);
    if (!ok) return false;
    await setPassword(next);
    return true;
  }

  Future<bool> removePassword(String current) async {
    final ok = await verify(current);
    if (!ok) return false;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_passwordKey);
    state = const PrivateNotesState(hasPassword: false);
    return true;
  }

  void removeAfterVerified() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.remove(_passwordKey);
    state = const PrivateNotesState(hasPassword: false);
  }

  void _markUnlocked() {
    state = state.copyWith(unlockedUntil: DateTime.now().add(sessionTtl));
  }

  void lock() {
    state = state.copyWith(clearUnlock: true);
  }

  static String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope'),
);

final privateNotesProvider =
    NotifierProvider<PrivateNotesController, PrivateNotesState>(
      PrivateNotesController.new,
    );
