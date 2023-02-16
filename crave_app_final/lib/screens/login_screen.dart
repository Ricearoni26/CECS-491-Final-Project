import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginScreen({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //Text Controllers - access text field input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Change button color when signing in
  Color _color = Colors.white;

  //Sign-in with Firebase
  Future signIn() async{
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
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  //Error Messages for logging in
  void displayErrorMsg(String message)
  {

    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: Colors.redAccent,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              )
            )
          );

        }
    );

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
                  child: GestureDetector(
                    onTap: signIn,
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
