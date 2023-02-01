import 'package:crave_app_final/screens/preferences_screen.dart';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:crave_app_final/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

const users = {
  'admin@gmail.com': '12345',
  'user@gmail.com': '12345',
  'a@gmail.com' : '12345',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  Duration get loginTime => const Duration(milliseconds: 2250);

  //Sign In Method
  Future<String?> _authUser(LoginData data) async{
    //print('Name: ${data.name}, Password: ${data.password}');
    String email = '${data.name}';
    String password = '${data.password}';

    try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }


    }

  }

  // Function below needs to be fixed
  Future<String?> _signupUser(SignupData data) async{
    String email = '${data.name}';
    String password = '${data.password}';
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch(e)
    {
      print(e);
    }
  }
  //debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
  //return Future.delayed(loginTime).then((_) {
  //Navigator.of(data as BuildContext).pushReplacement(MaterialPageRoute(
  //builder: (data) => const PreferencesScreen()
  //));
  //});

  Future<String?> _recoverPassword(String name) {
    //print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'Username does not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Crave',
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}

class LoginPage extends StatefulWidget
{

  @override
  State<StatefulWidget> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage>
{
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();

  }


  // Future<String?> _RegisterUser(SignupData data) async {
  //   String email = {data.password} as String;
  //   String password = {data.name} as String;
  //
  //   //await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  // }


}




