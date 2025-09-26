import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth_service.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({Key? key}) : super(key: key);

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  // New addition: FocusNode for handling cursor position
  final FocusNode _mobileFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Set the initial text to "+91"
    _mobileController.text = '+91';
    
    // Add a listener to keep the "+91" prefix
    _mobileController.addListener(() {
      if (!_mobileController.text.startsWith('+91')) {
        _mobileController.text = '+91';
        // Move the cursor to the end
        _mobileController.selection = TextSelection.fromPosition(
          TextPosition(offset: _mobileController.text.length),
        );
      }
    });

    // Add a listener to place the cursor correctly on focus
    _mobileFocusNode.addListener(() {
      if (_mobileFocusNode.hasFocus) {
        // Delay moving the cursor to ensure the keyboard is up
        Future.delayed(const Duration(milliseconds: 100), () {
          _mobileController.selection = TextSelection.fromPosition(
            TextPosition(offset: _mobileController.text.length),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose the focus node and listener
    _mobileFocusNode.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleUserLogin(BuildContext context) async {
    // Get the full mobile number as stored during signup
    final mobileNo = _mobileController.text.trim().replaceAll(' ', '');
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      final loginError = await _auth.loginUser(mobileNo, password);

      if (loginError != null) {
        _showSnackBar(context, loginError);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', mobileNo);
      
      _showSnackBar(context, 'User Login Successful!');
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/user-dashboard');
      }
    } catch (e) {
      _showSnackBar(context, 'Login failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Login'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white, // For better contrast
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _mobileController,
              focusNode: _mobileFocusNode, // New addition
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                hintText: '+911234567890',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleUserLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/user-signup');
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
