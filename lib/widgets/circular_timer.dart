import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

/// Circular animated study timer widget
class CircularTimer extends StatefulWidget {
  final int durationMinutes;
  final bool isStopwatch;
  final VoidCallback? onComplete;
  final Function(int remainingSeconds)? onTick;
  final Function(int completedMinutes)? onCancel;

  const CircularTimer({
    super.key,
    required this.durationMinutes,
    this.isStopwatch = false,
    this.onComplete,
    this.onTick,
    this.onCancel,
  });

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late Timer _clockTimer;
  late int _remainingSeconds;
  bool _isRunning = false;
  bool _isPaused = false;
  late AnimationController _controller;
  DateTime? _sessionStartTime;
  int _totalElapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isStopwatch) {
      _remainingSeconds = 0; // Start from 0 for stopwatch
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(hours: 24), // Max duration for stopwatch
      );
    } else {
      _remainingSeconds = widget.durationMinutes * 60;
      _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: _remainingSeconds),
      );
    }
    // Update clock every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update current time
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clockTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    final wasPaused = _isPaused;

    setState(() {
      _isRunning = true;
      if (!wasPaused) {
        // Starting fresh
        _sessionStartTime = DateTime.now();
        _totalElapsedSeconds = 0;
      } else {
        // Resuming from pause
        _sessionStartTime = DateTime.now();
      }
      _isPaused = false;
    });

    if (widget.isStopwatch) {
      // Stopwatch mode - count up
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isRunning) {
          timer.cancel();
          return;
        }

        final now = DateTime.now();
        final sessionStart = _sessionStartTime;
        if (sessionStart != null) {
          final elapsed = now.difference(sessionStart);
          final totalElapsed = _totalElapsedSeconds + elapsed.inSeconds;

          if (totalElapsed != _remainingSeconds) {
            setState(() {
              _remainingSeconds = totalElapsed;
              widget.onTick?.call(_remainingSeconds); // Elapsed seconds for stopwatch
            });
          }
        }
      });
    } else {
      // Normal timer mode - count down
      final totalSeconds = widget.durationMinutes * 60;
      final currentProgress = 1.0 - (_remainingSeconds / totalSeconds);

      if (!wasPaused) {
        _controller.value = currentProgress;
        _controller.forward();
      } else {
        // Resuming - continue from where we left off
        _controller.forward();
      }

      // Update more frequently for smoother animation (every 100ms)
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isRunning) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds > 0) {
          final now = DateTime.now();
          final sessionStart = _sessionStartTime;
          if (sessionStart != null) {
            final elapsed = now.difference(sessionStart);
            final newRemaining =
                totalSeconds - (_totalElapsedSeconds + elapsed.inSeconds);

            if (newRemaining != _remainingSeconds) {
              setState(() {
                _remainingSeconds = newRemaining.clamp(0, totalSeconds);
                widget.onTick?.call(_remainingSeconds);
              });
            }

            // Update controller smoothly
            final progress = 1.0 - (_remainingSeconds / totalSeconds);
            if ((_controller.value - progress).abs() > 0.001) {
              _controller.value = progress;
            }
          }
        } else {
          timer.cancel();
          setState(() {
            _isRunning = false;
          });
          _controller.value = 1.0;
          widget.onComplete?.call();
        }
      });
    }
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    // Calculate elapsed time in this session
    final sessionStart = _sessionStartTime;
    if (sessionStart != null) {
      final elapsed = DateTime.now().difference(sessionStart);
      _totalElapsedSeconds += elapsed.inSeconds;
    }

    setState(() {
      _isRunning = false;
      _isPaused = true;
    });

    _timer?.cancel();
    _controller.stop();
  }

  void _cancelTimer() {
    if (!_isRunning && !_isPaused) return;

    _timer?.cancel();

    // Calculate total completed minutes including current session
    int totalSeconds = _totalElapsedSeconds;
    final sessionStart = _sessionStartTime;
    if (sessionStart != null && _isRunning) {
      final currentSessionElapsed = DateTime.now().difference(sessionStart);
      totalSeconds += currentSessionElapsed.inSeconds;
    }

    final completedMinutes = (totalSeconds / 60).round();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _sessionStartTime = null;
      _totalElapsedSeconds = 0;
    });

    _controller.stop();
    widget.onCancel?.call(completedMinutes);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _getCompletedMinutes() {
    int totalSeconds = _totalElapsedSeconds;
    final sessionStart = _sessionStartTime;
    if (sessionStart != null && _isRunning) {
      final currentSessionElapsed = DateTime.now().difference(sessionStart);
      totalSeconds += currentSessionElapsed.inSeconds;
    }
    return (totalSeconds / 60).round();
  }

  int _getRemainingMinutes() {
    return (_remainingSeconds / 60).round();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final completedMinutes = _getCompletedMinutes();
    final remainingMinutes = _getRemainingMinutes();
    final currentTime = _getCurrentTime();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Time info cards with emojis
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Completed time
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.2),
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedMinutes min',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        inherit: false,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Current time
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.secondaryBlue.withValues(alpha: 0.2),
                      AppTheme.secondaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: AppTheme.secondaryBlue,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        inherit: false,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryBlue,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Remaining time (or elapsed time for stopwatch)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.xpCyan.withValues(alpha: 0.2),
                      AppTheme.xpCyan.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.isStopwatch ? Icons.timer : Icons.hourglass_empty,
                      size: 20,
                      color: AppTheme.xpCyan,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isStopwatch
                          ? '${(_remainingSeconds / 60).round()} min'
                          : '$remainingMinutes min',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        inherit: false,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.xpCyan,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Circular progress indicator
        SizedBox(
          width: AppConstants.circularTimerSize,
          height: AppConstants.circularTimerSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: AppConstants.circularTimerSize,
                height: AppConstants.circularTimerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: AppTheme.softGlow,
                ),
              ),
              // Progress circle (hidden for stopwatch)
              if (!widget.isStopwatch)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: AppConstants.circularTimerSize,
                      height: AppConstants.circularTimerSize,
                      child: CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: AppConstants.timerStrokeWidth,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(
                                AppTheme.primaryPurple,
                                AppTheme.xpCyan,
                                _controller.value,
                              ) ??
                              AppTheme.primaryPurple,
                        ),
                      ),
                    );
                  },
                ),
              // For stopwatch, show a static circle with gradient
              if (widget.isStopwatch)
                Container(
                  width: AppConstants.circularTimerSize,
                  height: AppConstants.circularTimerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPurple.withValues(alpha: 0.3),
                        AppTheme.secondaryBlue.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              // Time display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRunning
                        ? Icons.timer
                        : _isPaused
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 32,
                    color: _isRunning
                        ? AppTheme.primaryPurple
                        : _isPaused
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isStopwatch
                        ? _formatTime(_remainingSeconds)
                        : _formatTime(_remainingSeconds),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      inherit: false,
                      color: _isRunning
                          ? AppTheme.primaryPurple
                          : _isPaused
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isStopwatch
                        ? (_isRunning
                            ? 'Running'
                            : _isPaused
                                ? 'Paused'
                                : 'Ready')
                        : (_isRunning
                            ? 'Running'
                            : _isPaused
                                ? 'Paused'
                                : 'Ready'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel/Stop button (only show when running or paused)
            if (_isRunning || _isPaused) ...[
              Container(
                decoration: BoxDecoration(
                  color: widget.isStopwatch
                      ? AppTheme.primaryPurple.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _cancelTimer,
                  icon: Icon(
                    widget.isStopwatch ? Icons.stop : Icons.cancel_outlined,
                  ),
                  iconSize: 32,
                  color: widget.isStopwatch ? AppTheme.primaryPurple : Colors.red,
                  tooltip: widget.isStopwatch ? 'Stop' : 'Cancel Quest',
                ),
              ),
              const SizedBox(width: 24),
            ],
            // Start/Pause button with emoji
            Container(
              decoration: BoxDecoration(
                gradient: _isRunning
                    ? LinearGradient(
                        colors: [
                          AppTheme.secondaryBlue,
                          AppTheme.secondaryBlueDark,
                        ],
                      )
                    : AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.softGlow,
              ),
              child: ElevatedButton(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: const CircleBorder(),
                  minimumSize: const Size(80, 80),
                ),
                child: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
