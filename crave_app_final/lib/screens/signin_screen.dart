import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const SignInScreen({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  //Text Controllers - access text field input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  //Sign-in with Firebase
  Future signIn() async{
    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
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



  //Clean up memory management
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

              //Sign in button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child:GestureDetector(
                  onTap: signIn,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                        color: Colors.lightBlueAccent
                    ),
                    child: Center(
                      child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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
                      'Not a member? ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                    ,),
                  GestureDetector(
                    onTap: widget.showRegisterPage,
                    child: Text(
                    'Register Now!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,


                    )
                  ),
          )
                ],
              )


            ], )
          )
      )
    )
    );//Container(decoration: BoxDecoration(gradient: LinearGradient(colors:  [Colors.red, Colors.orange, Colors.yellow] ,begin: Alignment.topLeft, end: Alignment.bottomRight,))),


  }
}
