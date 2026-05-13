import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _cpfController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _floatingController;
  late Animation<double> _logoScale;
  late Animation<double> _formSlide;
  late Animation<double> _floatingAnimation;
  late final AnimationController _copaReflexoController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _copaReflexoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();

    _logoScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );

    _formController.forward();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _floatingController.dispose();
    _cpfController.dispose();
    _copaReflexoController.dispose();

    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cpf = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpf.length != 11) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'CPF deve conter 11 dígitos';
      });
      return;
    }

    final user = await ApiService.login(cpf);

    if (user != null) {
      setState(() {
        _isLoading = false;
      });

      widget.onLogin(user);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'CPF inserido incorreto.\n\nSe seus dados estão corretos, procure uma de nossas lojas.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fill,
            ),
          ),

          Positioned.fill(
            child: Opacity(
              opacity: 0.85,
              child: Transform.translate(
                offset: const Offset(-220, 0),
                child: Image.asset(
                  'assets/taca_copa.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),

          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 80 + _floatingAnimation.value,
                    left: 24,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.white.withValues(alpha: 0.07).withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.07).withValues(alpha: 0.2)],
                          center: const Alignment(-0.3, -0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.07).withValues(alpha: 0.3),
                            blurRadius: 48 * 0.3,
                            spreadRadius: 48 * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 180 - _floatingAnimation.value,
                    right: 54,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFFFC107).withValues(alpha: 0.12).withValues(alpha: 0.8), Color(0xFFFFC107).withValues(alpha: 0.12).withValues(alpha: 0.2)],
                          center: const Alignment(-0.3, -0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFC107).withValues(alpha: 0.12).withValues(alpha: 0.3),
                            blurRadius: 38 * 0.3,
                            spreadRadius: 38 * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 300 - _floatingAnimation.value,
                    right: 80,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.amber.withValues(alpha: 0.15).withValues(alpha: 0.8), Colors.amber.withValues(alpha: 0.15).withValues(alpha: 0.2)],
                          center: const Alignment(-0.3, -0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.15).withValues(alpha: 0.3),
                            blurRadius: 50 * 0.3,
                            spreadRadius: 50 * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 58 + _floatingAnimation.value * 1.2,
                    right: -28,
                    child: Transform.rotate(
                      angle: _floatingAnimation.value * 0.025,
                      child: SizedBox(
                        width: 118 + 36,
                        height: 118 + 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 6,
                              child: Container(
                                width: 118 + 28,
                                height: 118 + 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFFFC107).withValues(alpha: 0.34),
                                      const Color(0xFFFFC107).withValues(alpha: 0.10),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 14,
                              child: Container(
                                width: 118 + 10,
                                height: 118 + 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 18,
                              child: Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.34),
                                      blurRadius: 22,
                                      offset: const Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      blurRadius: 8,
                                      offset: const Offset(-4, -4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/bola_copa.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 58 + _floatingAnimation.value * 1.2,
                    left: -28,
                    child: Transform.rotate(
                      angle: _floatingAnimation.value * 0.025,
                      child: SizedBox(
                        width: 118 + 36,
                        height: 118 + 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 6,
                              child: Container(
                                width: 118 + 28,
                                height: 118 + 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFFFC107).withValues(alpha: 0.34),
                                      const Color(0xFFFFC107).withValues(alpha: 0.10),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 14,
                              child: Container(
                                width: 118 + 10,
                                height: 118 + 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 18,
                              child: Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.34),
                                      blurRadius: 22,
                                      offset: const Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      blurRadius: 8,
                                      offset: const Offset(-4, -4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/bola_copa.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AnimatedBuilder(
                  animation: _formSlide,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _formSlide.value),
                      child: Opacity(
                        opacity: 1 - (_formSlide.value / 50),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFCC0000), Color(0xFF990000)],
                              ),
                            ),
                            child: Column(
                              children: [
                                ScaleTransition(
                                  scale: _logoScale,
                                  child: ClipRRect(
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.cover,
                                      height: 160,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: AnimatedBuilder(
                                    animation: _copaReflexoController,
                                    builder: (context, _) {
                                      return Stack(
                                        clipBehavior: Clip.hardEdge,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFFFFE082),
                                                  Color(0xFFFFC107),
                                                  Color(0xFFFFA000),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.55),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amber.withValues(alpha: 0.45),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              'COPA DO MUNDO 2026',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black87,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ),

                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: Transform.translate(
                                                offset: Offset(
                                                  -100 + (_copaReflexoController.value * 260),
                                                  0,
                                                ),
                                                child: Transform.rotate(
                                                  angle: -0.45,
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(
                                                      width: 38,
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            Colors.white.withValues(alpha: 0),
                                                            Colors.white.withValues(alpha: 0.65),
                                                            Colors.white.withValues(alpha: 0),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CPF',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _cpfController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [CpfInputFormatter()],
                                    onSubmitted: (value) {
                                      _isLoading ? null : _login();
                                    },
                                    decoration: InputDecoration(
                                      hintText: '000.000.000-00',
                                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade500),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCC0000), width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ),

                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.red.shade50, Colors.red.shade100],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 22),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFCC0000),
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: Colors.red.shade300,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 68,
                                            height: 58,
                                            child: ColorFiltered(
                                              colorFilter: const ColorFilter.mode(
                                                Colors.black,
                                                BlendMode.srcIn,
                                              ),
                                              child: Lottie.asset(
                                                'assets/animations/football_loading.json',
                                                fit: BoxFit.fill,
                                                repeat: true,
                                                animate: true,
                                              ),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.login, size: 22),
                                              SizedBox(width: 10),
                                              Text(
                                                'ENTRAR',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Participe do bolão da Copa 2026',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'R\$ 5,00/jogo ou R\$ 520,00 todos',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                GestureDetector(
                                  onLongPress: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminLoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.admin_panel_settings,
                                          color: Colors.grey.shade500,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Configurações avançadas',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      }

      if (i == 9) {
        buffer.write('-');
      }

      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
