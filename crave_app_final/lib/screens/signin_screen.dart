import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
        body: SafeArea(
        child: Center(
          child: Column(children: [
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
                      decoration: InputDecoration(
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
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    )
                ),
              ),
            ),

            SizedBox(height: 15),

            Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(color: Colors.lightBlueAccent),
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

            SizedBox(height: 15),


            //Implement Register


          ], )
      )
    )
    );//Container(decoration: BoxDecoration(gradient: LinearGradient(colors:  [Colors.red, Colors.orange, Colors.yellow] ,begin: Alignment.topLeft, end: Alignment.bottomRight,))),


  }
}
