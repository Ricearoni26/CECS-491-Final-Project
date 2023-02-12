import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool showPass = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Info Screen'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 10, color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  "https://media.tenor.com/_ha2H2_hlhEAAAAM/wazowski-mike.gif"))),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 4,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                            color: Colors.orange,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              buildTextField("First Name","Tap", false),
              buildTextField("Last Name", "Tap", false),
              buildTextField("E-mail", "Tap", false),
              buildTextField("Password", "Tap", true),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String name, String hint, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          suffixIcon: isPassword
              ? IconButton(
            onPressed: () {
              
            },
            icon: Icon(Icons.remove_red_eye, color: Colors.grey),
          )
              : null,
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: name,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }



}
