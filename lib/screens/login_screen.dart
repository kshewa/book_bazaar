import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getFriendlyErrorMessage(e.code));
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }

    setState(() => _isLoading = false);
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return '📖 No account found with this email';
      case 'wrong-password': return '🔐 Incorrect password. Please try again';
      case 'email-already-in-use': return '📚 An account already exists with this email';
      case 'weak-password': return '🔒 Password should be at least 6 characters';
      case 'invalid-email': return '✉️ Please enter a valid email address';
      default: return '⚠️ Authentication error. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Color(0xFF0a0a1a),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.2, 0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1a1a3a),
                    Color(0xFF0a0a1a),
                    Color(0xFF050510),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            // Floating Books
            ...List.generate(6, (index) => _FloatingBook(index)),
            
            // Main Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight * 0.05),
                          
                          // Animated Book Logo
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 600),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: screenWidth * 0.22,
                                  height: screenWidth * 0.22,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF667eea).withOpacity(0.4),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.auto_stories_rounded,
                                    size: screenWidth * 0.12,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Glowing Title
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Color(0xFFa78bfa), Color(0xFFc084fc), Color(0xFFe879f9)],
                            ).createShader(bounds),
                            child: Text(
                              'Book Bazaar',
                              style: TextStyle(
                                fontSize: screenWidth * 0.11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Tagline
                          Text(
                            _isLoginMode ? '📖 Discover your next great read' : '🌟 Join 10,000+ book lovers',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.05),
                          
                          // Toggle Buttons
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                _toggleButton('Sign In', true, screenWidth),
                                SizedBox(width: 8),
                                _toggleButton('Sign Up', false, screenWidth),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.03),
                          
                          // Email Field - Fixed yellow/black underline issue
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                            ),
                            child: TextField(
                              controller: _emailController,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: screenWidth * 0.035,
                                ),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.white54, size: 22),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Password Field - Fixed yellow/black underline issue
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                              ),
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: screenWidth * 0.035,
                                ),
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54, size: 22),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              ),
                            ),
                          ),
                          
                          // Forgot Password
                          if (_isLoginMode)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _showForgotPasswordDialog(),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFFa78bfa),
                                    fontSize: screenWidth * 0.032,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Error Message
                          if (_errorMessage.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: screenHeight * 0.02),
                              padding: EdgeInsets.all(screenHeight * 0.012),
                              decoration: BoxDecoration(
                                color: Color(0xFFef4444).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Color(0xFFef4444).withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Color(0xFFfca5a5), size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(color: Color(0xFFfca5a5), fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          SizedBox(height: screenHeight * 0.025),
                          
                          // Submit Button - FIXED: Properly clickable
                          if (_isLoading)
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _submit,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF667eea).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLoginMode ? 'Sign In' : 'Create Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: screenWidth * 0.032),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                            ],
                          ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Social Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(Icons.g_mobiledata, screenWidth),
                              SizedBox(width: screenWidth * 0.05),
                              _socialButton(Icons.facebook, screenWidth),
                              SizedBox(width: screenWidth * 0.05),
                              _socialButton(Icons.apple, screenWidth),
                            ],
                          ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Toggle Mode
                          GestureDetector(
                            onTap: () => setState(() => _isLoginMode = !_isLoginMode),
                            child: Text(
                              _isLoginMode
                                  ? "New to Book Bazaar? ✨ Create account"
                                  : "Already have an account? 📚 Sign in",
                              style: TextStyle(
                                color: Color(0xFFc084fc),
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.03),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String text, bool isLogin, double screenWidth) {
    final isActive = (isLogin == _isLoginMode);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLoginMode = isLogin),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive 
                ? LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])
                : null,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.038,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, double screenWidth) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Social login coming soon!')),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white70, size: 24),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1E1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_reset, size: 48, color: Color(0xFFa78bfa)),
              SizedBox(height: 16),
              Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Enter your email to receive reset instructions', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667eea),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Send Reset Email'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Floating Book Widget
class _FloatingBook extends StatefulWidget {
  final int index;
  _FloatingBook(this.index);

  @override
  __FloatingBookState createState() => __FloatingBookState();
}

class __FloatingBookState extends State<_FloatingBook> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.index % 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positions = [
      Alignment(-0.85, -0.9),
      Alignment(0.85, -0.85),
      Alignment(-0.7, 0.85),
      Alignment(0.8, 0.8),
      Alignment(0.4, -0.92),
      Alignment(-0.88, -0.3),
    ];
    
    final sizes = [60.0, 70.0, 50.0, 80.0, 45.0, 65.0];
    
    return Positioned(
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Align(
              alignment: positions[widget.index % positions.length],
              child: Opacity(
                opacity: 0.04,
                child: Icon(
                  Icons.book,
                  size: sizes[widget.index % sizes.length],
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}