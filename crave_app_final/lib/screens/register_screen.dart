import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //Text Controllers - access text field input
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //Clean up memory management
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  //Register accounts to Firebase
  Future signUp() async
  {
    //Password entered correctly (twice)
    if(confirmPassword())
    {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());
        } on FirebaseAuthException catch (e) {
              displayErrorMsg(e.code);
        }

        //Add user details
        addUserDetails();


      }
  }

  //Check if confirm password matches
  bool confirmPassword()
  {
    //Passwords Match
    if(_passwordController.text.trim() == _confirmPasswordController.text.trim())
      {
          return true;
      }
    //Passwords do not match
    else
      {
          displayErrorMsg('Passwords do not match');
          return false;
      }
  }


  Future addUserDetails() async{
    FirebaseDatabase database = FirebaseDatabase.instance;
    final user = FirebaseAuth.instance.currentUser!;
    String UID = user.uid!;

    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(UID);
    await ref.set({'firstName': _firstNameController.text.trim(),
                  'lastName': _lastNameController.text.trim() });

  }

  //Error Messages for registering
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
                        const SizedBox(height: 30),
                        const Text('Crave',
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        //First Name TextField
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(padding: const EdgeInsets.only(left:20.0),
                                child:TextField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    border: InputBorder.none,
                                    hintText: 'First Name',
                                  ),
                                )
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        //Last Name TextField
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(padding: const EdgeInsets.only(left:20.0),
                                child:TextField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    border: InputBorder.none,
                                    hintText: 'Last Name',
                                  ),
                                )
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

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
                                  decoration: const InputDecoration(
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

                        //Confirm Password Textfield
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(padding: const EdgeInsets.only(left:20.0),
                                child:TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline),
                                    border: InputBorder.none,
                                    hintText: 'Confirm Password',
                                  ),
                                )
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        //Sign up button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: GestureDetector(
                            onTap: signUp,
                            child: SizedBox(
                              width: 200, // set a specific width
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.lightBlueAccent,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: const Center(
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

                        const SizedBox(height: 15),
                        //Implement Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'I am a member. ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )
                              ,),
                            GestureDetector(
                              onTap: widget.showLoginPage,
                              child: const Text(
                                  'Login now!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  )
                              ),
                            )
                          ],
                        )
                      ],
                    )
                )
            )
        )
    );
  }
}
