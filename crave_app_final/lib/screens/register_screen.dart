import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
    
class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //Text Controllers - access text field input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Clean up memory management
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //Register accounts to Firebase
  Future signUp() async
  {

    try {

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      }
      else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');

      }

    }


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
                        Text('Crave',
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 20),

                        //Email Textfield
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(padding: const EdgeInsets.only(left:20.0),
                                child:TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.email),
                                    border: InputBorder.none,
                                    hintText: 'Email',
                                  ),
                                )
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        //Password Textfield
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(padding: const EdgeInsets.only(left:20.0),
                                child:TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline),
                                    border: InputBorder.none,
                                    hintText: 'Password',
                                  ),
                                )
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        //Sign up button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: GestureDetector(
                            onTap: signUp,
                            child: Container(
                              width: 200, // set a specific width
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.lightBlueAccent,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),


                        //Implement Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'I am a member. ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )
                              ,),
                            GestureDetector(
                              onTap: widget.showLoginPage,
                              child: Text(
                                  'Login now!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,


                                  )
                              ),
                            )
                          ],
                        )


                      ], )
                )
            )
        )
    );
  }
}
