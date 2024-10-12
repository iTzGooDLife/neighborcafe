import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class SessionTimeoutManager extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutManager({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 30),
  });

  @override
  _SessionTimeoutManagerState createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _lastInteraction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_lastInteraction != null) {
        final now = DateTime.now();
        final difference = now.difference(_lastInteraction!);
        if (difference >= widget.timeoutDuration) {
          _handleTimeout();
        } else {
          _resetTimer();
        }
      }
    } else if (state == AppLifecycleState.paused) {
      _lastInteraction = DateTime.now();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  void _handleTimeout() {
    context.read<AuthService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
