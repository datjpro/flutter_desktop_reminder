import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../utils/modern_theme.dart';

class LuxuryClockWidget extends StatefulWidget {
  final double size;
  final bool showDigital;
  final bool showDate;
  final Color? primaryColor;
  final Color? secondaryColor;

  const LuxuryClockWidget({
    super.key,
    this.size = 200,
    this.showDigital = true,
    this.showDate = true,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<LuxuryClockWidget> createState() => _LuxuryClockWidgetState();
}

class _LuxuryClockWidgetState extends State<LuxuryClockWidget>
    with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background with gradient
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.primaryColor ?? ModernAppTheme.primaryPurple,
                  widget.secondaryColor ?? ModernAppTheme.primaryPurpleDark,
                ],
                stops: const [0.7, 1.0],
              ),
              boxShadow: [
                ModernAppTheme.mediumShadow,
                BoxShadow(
                  color: (widget.primaryColor ?? ModernAppTheme.primaryPurple).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          
          // Animated border
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ModernAppTheme.accentOrange.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Clock face
          _buildClockFace(),
          
          // Hour markers
          _buildHourMarkers(),
          
          // Clock hands
          _buildClockHands(),
          
          // Center dot
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 12 + (_pulseController.value * 4),
                height: 12 + (_pulseController.value * 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ModernAppTheme.accentOrange,
                  boxShadow: [
                    BoxShadow(
                      color: ModernAppTheme.accentOrange.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Digital time display
          if (widget.showDigital)
            Positioned(
              bottom: widget.size * 0.25,
              child: _buildDigitalDisplay(),
            ),
          
          // Date display
          if (widget.showDate)
            Positioned(
              top: widget.size * 0.25,
              child: _buildDateDisplay(),
            ),
        ],
      ),
    );
  }

  Widget _buildClockFace() {
    return Container(
      width: widget.size * 0.9,
      height: widget.size * 0.9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ModernAppTheme.textDark.withOpacity(0.1),
        border: Border.all(
          color: ModernAppTheme.textDark.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildHourMarkers() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: List.generate(12, (index) {
          final angle = (index * 30) * math.pi / 180;
          final isMainHour = index % 3 == 0;
          
          return Transform.rotate(
            angle: angle,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: widget.size * 0.1),
                width: isMainHour ? 3 : 2,
                height: isMainHour ? 20 : 15,
                decoration: BoxDecoration(
                  color: ModernAppTheme.textDark.withOpacity(isMainHour ? 0.9 : 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClockHands() {
    final hours = _now.hour % 12;
    final minutes = _now.minute;
    final seconds = _now.second;
    
    final hourAngle = (hours * 30 + minutes * 0.5) * math.pi / 180;
    final minuteAngle = minutes * 6 * math.pi / 180;
    final secondAngle = seconds * 6 * math.pi / 180;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Hour hand
        Transform.rotate(
          angle: hourAngle,
          child: Container(
            width: 4,
            height: widget.size * 0.3,
            margin: EdgeInsets.only(bottom: widget.size * 0.3),
            decoration: BoxDecoration(
              color: ModernAppTheme.textDark.withOpacity(0.9),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        
        // Minute hand
        Transform.rotate(
          angle: minuteAngle,
          child: Container(
            width: 3,
            height: widget.size * 0.4,
            margin: EdgeInsets.only(bottom: widget.size * 0.4),
            decoration: BoxDecoration(
              color: ModernAppTheme.textDark.withOpacity(0.9),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        
        // Second hand
        Transform.rotate(
          angle: secondAngle,
          child: Container(
            width: 2,
            height: widget.size * 0.45,
            margin: EdgeInsets.only(bottom: widget.size * 0.45),
            decoration: BoxDecoration(
              color: ModernAppTheme.accentOrange,
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: ModernAppTheme.accentOrange.withOpacity(0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernAppTheme.accentOrange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        DateFormat('HH:mm:ss').format(_now),
        style: const TextStyle(
          color: ModernAppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ModernAppTheme.textDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernAppTheme.textDark.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        DateFormat('MMM dd').format(_now),
        style: const TextStyle(
          color: ModernAppTheme.textDark,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Compact Clock Widget for smaller spaces
class CompactClockWidget extends StatefulWidget {
  final double size;
  final bool showDate;
  final Color? color;

  const CompactClockWidget({
    super.key,
    this.size = 60,
    this.showDate = false,
    this.color,
  });

  @override
  State<CompactClockWidget> createState() => _CompactClockWidgetState();
}

class _CompactClockWidgetState extends State<CompactClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: widget.size * 0.8,
            height: widget.size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  widget.color ?? ModernAppTheme.primaryPurple,
                  (widget.color ?? ModernAppTheme.primaryPurple).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [ModernAppTheme.lightShadow],
            ),
            child: Center(
              child: Text(
                DateFormat('HH:mm').format(_now),
                style: TextStyle(
                  color: ModernAppTheme.textDark,
                  fontSize: widget.size * 0.2,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          if (widget.showDate)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                DateFormat('MMM dd').format(_now),
                style: TextStyle(
                  color: widget.color ?? ModernAppTheme.primaryPurple,
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// World Clock Widget
class WorldClockWidget extends StatefulWidget {
  final String timezone;
  final String cityName;
  final double size;

  const WorldClockWidget({
    super.key,
    required this.timezone,
    required this.cityName,
    this.size = 120,
  });

  @override
  State<WorldClockWidget> createState() => _WorldClockWidgetState();
}

class _WorldClockWidgetState extends State<WorldClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: ModernAppTheme.backgroundGradient,
        borderRadius: ModernAppTheme.radiusMedium,
        boxShadow: [ModernAppTheme.lightShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.cityName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ModernAppTheme.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('HH:mm').format(_now),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ModernAppTheme.primaryPurple,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM dd').format(_now),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ModernAppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
