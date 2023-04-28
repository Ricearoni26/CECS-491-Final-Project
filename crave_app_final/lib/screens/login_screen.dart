import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginScreen({Key? key, required this.showRegisterPage})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Text Controllers - access text field input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();



  //Change button color when signing in
  Color _buttonColor = Colors.lightBlueAccent;
  bool _isButtonPressed = false;
  //Change button color when signing in
  Color _color = Colors.white;

  //Sign-in with Firebase
  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      displayErrorMsg(e.code);
    }
  }

  //Clean up memory management
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //Error Messages for logging in
  void displayErrorMsg(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  )));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  const Text(
                    'Crave',
                    style: TextStyle(
                      fontSize: 60,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  //Email Textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              border: InputBorder.none,
                              hintText: 'Email',
                            ),
                          )),
                    ),
                  ),

                  const SizedBox(height: 15),

                  //Password Textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              border: InputBorder.none,
                              hintText: 'Password',
                            ),
                          )),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Sign-in button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 2000),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _isButtonPressed ? Colors.green : _buttonColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: _isButtonPressed ? 50 : 200,
                      height: 50,
                      child: _isButtonPressed
                          ? const Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      )
                          : InkWell(
                        onTap: () {
                          setState(() {
                            _isButtonPressed = true;
                            _buttonColor = Colors.green;
                          });
                          signIn().then((value) => setState(() {
                            _isButtonPressed = false;
                            _buttonColor = Colors.lightBlueAccent;
                          }));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 2000),
                          curve: Curves.easeInOut,
                          width: _isButtonPressed ? 50 : 200,
                          height: 50,
                          child: Center(
                            child: Text(
                              _isButtonPressed ? "" : "Sign In",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  //Implement Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Not a member? ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: const Text(
                          'Register Now!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
