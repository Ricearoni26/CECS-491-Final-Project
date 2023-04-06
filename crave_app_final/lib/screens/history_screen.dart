import 'package:flutter/material.dart';

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class HistoryScreen extends StatelessWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();


  Future<String> displayUserDetails() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference refUser = FirebaseDatabase.instance.ref('users/$uid');

    final Completer<String> completer = Completer<String>();

    refUser.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final fullName = '${data['firstName']} ${data['lastName']} ${data['preferences']['Additional services']} ';
      print('Full name: $fullName');
      completer.complete(fullName);
    });

    final String fullName = await completer.future;
    print('Returning full name: $fullName');
    return fullName;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food History'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: displayUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Text(snapshot.data ?? '');
          },
        ),
      ),
    );
  }
}
