import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/pro_promotion_dialog.dart';
import 'main_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _patternController;
  late AnimationController _progressController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoBreathAnimation;

  int _loadingStep = 0;
  final List<String> _loadingTexts = [
    'Initializing workspace...',
    'Loading AI models...',
    'Preparing your prompts...',
    'Finalizing setup...',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
    _startLoadingTextCycle();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _patternController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack),
    ));

    _slideAnimation = Tween<double>(
      begin: 60.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
    ));

    _logoBreathAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _mainController.forward();
    _progressController.forward();
  }

  void _startLoadingTextCycle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted && _loadingStep < _loadingTexts.length - 1) {
        setState(() => _loadingStep++);
        return true;
      }
      return false;
    });
  }

  Future<void> _initializeApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    await Future.delayed(const Duration(milliseconds: 1200));
    await appProvider.initialize();
    
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 1600));
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.1, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 900),
        ),
      );
      _showProPromotionIfNeeded();
    }
  }

  Future<void> _showProPromotionIfNeeded() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt('pro_dialog_last_shown') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLastShown = (now - lastShown) / (1000 * 60 * 60 * 24);

    if (daysSinceLastShown >= 2 || lastShown == 0) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const ProPromotionDialog(),
        );
        await prefs.setInt('pro_dialog_last_shown', now);
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _patternController.dispose();
    _progressController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBF8),
              Color(0xFFFFF8F5),
              Color(0xFFFFFAF7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Sophisticated geometric pattern layer
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _patternController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SophisticatedPatternPainter(
                      animation: _patternController.value,
                    ),
                    size: size,
                  );
                },
              ),
            ),

            // Particle system overlay
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticleSystemPainter(
                      animation: _particleController.value,
                      size: size,
                    ),
                  );
                },
              ),
            ),

            // Gradient mesh overlay
            Positioned.fill(
              child: CustomPaint(
                painter: GradientMeshPainter(),
              ),
            ),

            // Main content
            SafeArea(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        const Spacer(flex: 5),
                        
                        // Logo section
                        Transform.translate(
                          offset: Offset(0, -_slideAnimation.value),
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: AnimatedBuilder(
                              animation: _logoBreathAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _logoBreathAnimation.value,
                                  child: _buildLogoSection(),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // App branding
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.4),
                          child: _buildBrandingSection(),
                        ),
                        
                        const Spacer(flex: 4),
                        
                        // Loading section
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.2),
                          child: Consumer<AppProvider>(
                            builder: (context, provider, child) {
                              if (provider.error.isNotEmpty) {
                                return _buildErrorState(provider);
                              }
                              return _buildLoadingState();
                            },
                          ),
                        ),
                        
                        const Spacer(flex: 2),
                        
                        // Footer
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.15),
                          child: _buildFooter(),
                        ),
                        
                        const SizedBox(height: 50),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow rings
        for (int i = 0; i < 3; i++)
          Container(
            width: 140 + (i * 25.0),
            height: 140 + (i * 25.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.vaultRed.withOpacity(0.08 - (i * 0.02)),
                width: 1.5,
              ),
            ),
          ),
        
        // Main logo container
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppConstants.vaultRed.withOpacity(0.2),
                blurRadius: 50,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.vaultRed,
                  AppConstants.vaultRed.withOpacity(0.85),
                  const Color(0xFFFF4757),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                // Glossy overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 65,
                    height: 65,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF1A252F),
              ],
            ).createShader(bounds);
          },
          child: Text(
            AppConstants.appName,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.vaultRed.withOpacity(0.08),
                AppConstants.vaultRed.withOpacity(0.12),
                AppConstants.vaultRed.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppConstants.vaultRed.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppConstants.vaultRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.vaultRed.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppConstants.appTagline.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.vaultRed.withOpacity(0.9),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppConstants.vaultRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.vaultRed.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          // Sophisticated progress bar
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressController.value,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppConstants.vaultRed,
                            const Color(0xFFFF6B6B),
                            AppConstants.vaultRed,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.vaultRed.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 28),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: Text(
              _loadingTexts[_loadingStep],
              key: ValueKey<int>(_loadingStep),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A5A5A),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppConstants.errorColor.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: AppConstants.errorColor.withOpacity(0.9),
              size: 42,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Connection Failed',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to reach server.\nPlease check your connection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF5A5A5A).withOpacity(0.8),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: provider.initialize,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: AppConstants.errorColor.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 22),
                SizedBox(width: 10),
                Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 50,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF5A5A5A).withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: AppConstants.vaultRed.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'POWERED BY ADVANCED AI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5A5A5A).withOpacity(0.5),
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Sophisticated pattern painter with complex geometries
class SophisticatedPatternPainter extends CustomPainter {
  final double animation;

  SophisticatedPatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Hexagonal grid pattern
    _drawHexagonalGrid(canvas, size, paint);
    
    // Flowing curves network
    _drawFlowingNetwork(canvas, size, paint);
    
    // Spiral patterns
    _drawSpiralPatterns(canvas, size, paint);
    
    // Intersecting circles
    _drawIntersectingCircles(canvas, size, paint);
  }

  void _drawHexagonalGrid(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 0.8;
    final hexSize = 40.0;
    final rows = (size.height / (hexSize * 1.5)).ceil() + 2;
    final cols = (size.width / (hexSize * math.sqrt(3))).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final offsetX = col * hexSize * math.sqrt(3) + (row % 2) * hexSize * math.sqrt(3) / 2;
        final offsetY = row * hexSize * 1.5;
        
        final animOffset = math.sin(animation * 2 * math.pi + row * 0.1 + col * 0.1) * 3;
        
        paint.color = AppConstants.vaultRed.withOpacity(0.04 + animOffset.abs() * 0.01);
        
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (math.pi / 3 * i) + (animation * 0.5);
          final x = offsetX + hexSize * math.cos(angle);
          final y = offsetY + hexSize * math.sin(angle) + animOffset;
          
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawFlowingNetwork(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 1.2;
    
    for (int i = 0; i < 15; i++) {
      final path = Path();
      final yBase = (i / 15) * size.height;
      final phase = animation * 2 * math.pi + i * 0.4;
      
      paint.color = AppConstants.vaultRed.withOpacity(0.06);
      
      path.moveTo(0, yBase);
      
      for (double x = 0; x < size.width; x += 20) {
        final y = yBase + 
                  math.sin(x / 60 + phase) * 30 + 
                  math.sin(x / 100 + phase * 1.5) * 20;
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawSpiralPatterns(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    final centers = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.5),
    ];
    
    for (var center in centers) {
      for (int spiral = 0; spiral < 3; spiral++) {
        final path = Path();
        final startAngle = animation * 2 * math.pi + spiral * (math.pi * 2 / 3);
        
        for (double t = 0; t < math.pi * 4; t += 0.1) {
          final radius = 20 + t * 8;
          final angle = startAngle + t;
          final x = center.dx + radius * math.cos(angle);
          final y = center.dy + radius * math.sin(angle);
          
          if (t == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        
        paint.color = AppConstants.vaultRed.withOpacity(0.03);
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawIntersectingCircles(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;
    
    final gridX = 6;
    final gridY = 8;
    
    for (int i = 0; i < gridX; i++) {
      for (int j = 0; j < gridY; j++) {
        final x = (i / gridX) * size.width;
        final y = (j / gridY) * size.height;
        final radiusAnim = math.sin(animation * 2 * math.pi + i * 0.3 + j * 0.3);
        final radius = 30 + radiusAnim * 8;
        
        paint.color = AppConstants.vaultRed.withOpacity(0.025 + radiusAnim.abs() * 0.015);
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SophisticatedPatternPainter oldDelegate) => true;
}

// Particle system for ambient movement
class ParticleSystemPainter extends CustomPainter {
  final double animation;
  final Size size;

  ParticleSystemPainter({required this.animation, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    
    for (int i = 0; i < 40; i++) {
      final seedX = random.nextDouble();
      final seedY = random.nextDouble();
      final speedX = random.nextDouble() * 0.5 - 0.25;
      final speedY = random.nextDouble() * 0.3 - 0.15;
      
      final x = ((seedX + animation * speedX) % 1.0) * size.width;
      final y = ((seedY + animation * speedY) % 1.0) * size.height;
      
      final particleSize = 2 + random.nextDouble() * 3;
      final opacity = 0.03 + random.nextDouble() * 0.04;
      
      paint.color = AppConstants.vaultRed.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticleSystemPainter oldDelegate) => true;
}

// Gradient mesh overlay for depth
class GradientMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Radial gradient spots
    final spots = [
      {'pos': Offset(size.width * 0.2, size.height * 0.3), 'radius': 200.0},
      {'pos': Offset(size.width * 0.8, size.height * 0.7), 'radius': 250.0},
      {'pos': Offset(size.width * 0.5, size.height * 0.5), 'radius': 300.0},
    ];
    
    for (var spot in spots) {
      final pos = spot['pos'] as Offset;
      final radius = spot['radius'] as double;
      
      paint.shader = RadialGradient(
        colors: [
          AppConstants.vaultRed.withOpacity(0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));
      
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(GradientMeshPainter oldDelegate) => false;
}