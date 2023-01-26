import 'package:crave_app_final/screens/preferences_screen.dart';

import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

const users = {
  'admin@gmail.com': '12345',
  'user@gmail.com': '12345',
  'a@gmail.com' : '12345',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    //print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'Username does not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  // Function below needs to be fixed
  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      Navigator.of(data as BuildContext).pushReplacement(MaterialPageRoute(
          builder: (data) => const PreferencesScreen()
      ));
    });
  }

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
