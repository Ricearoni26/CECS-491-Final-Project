import 'package:crave_app_final/screens/Password_screen.dart';
import 'package:crave_app_final/screens/Payments_screen.dart';
import 'package:crave_app_final/screens/Personal_info_screen.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
          backgroundColor: Colors.orange,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 10),
                  Text("Account",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
                ],
              ),
              Divider(height: 20, thickness: 1),
              SizedBox(height: 10),
              buildAccountOption(context, "Personal and account information"),
              buildAccountOption(context, "Security"),
              buildAccountOption(context, "Payments"),
              
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(height: 10),
                  Icon(
                    Icons.security,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 10),
                  Text("Blah",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
                ],
              ),
              Divider(height: 20, thickness: 1),
              SizedBox(height: 10),
              buildAccountOption(context, "Blah Blah Blah Blah"),
              buildAccountOption(context, "Blah Blah Blah Blah"),
              buildAccountOption(context, "Blah Blah Blah Blah"),
            ],
          ),
        ));
  }

  GestureDetector buildAccountOption(BuildContext context, String Title) {
    return GestureDetector(
      onTap: () {
        if (Title == "Personal and account information") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PersonalInfoScreen()),
          );
        } else if (Title == "Password and Security") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PasswordScreen()),
          );
        } else if (Title == "Payments") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentsScreen()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600])),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}