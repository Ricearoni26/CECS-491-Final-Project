import 'package:crave_app_final/auth/auth_page.dart';
import 'package:crave_app_final/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class deleteScreen extends StatelessWidget {
  //constant constructor
  const deleteScreen({super.key});

  //const auth = getAuth();

  @override
  Widget build(BuildContext context) {
    /*return TextButton(
      onPressed: () =>
          showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  title: const Text('This account will be deleted permanently'),
                  content: const Text('Are you sure you want to continue?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          ),
      child: const Text('Show Dialog'),
    );*/
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Delete Current Account'),
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    title: const Text('This account will be deleted permanently'),
                    content: const Text('Are you sure you want to continue?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteUser();
                          FirebaseAuth.instance.signOut();
                          Navigator.push(
                          context,
                      MaterialPageRoute(

                      builder: (context) => const AuthPage(),
                      ),
                      );
                        },//on pressed
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
            child: const Text('Show Dialog');
          },
        ),
      ),
    );

  }

    //Sign-in with Firebase
    Future deleteUser() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // The user's ID, unique to the Firebase project. Do NOT use this value to
        // authenticate with your backend server, if you have one. Use
        // User.getIdToken() instead.
        final uid = user.uid;
        print(uid);
      }
      //deletes the user
      await user?.delete();
    }
  }

