// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// final FirebaseAuth _auth = FirebaseAuth.instance;
//
//
// class PersonalInfoScreen extends StatefulWidget {
//   const PersonalInfoScreen({Key? key});
//
//   @override
//   State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
// }
//
// class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
//   bool showPassword = true;
//
//   @override
//   Widget build(BuildContext context) {
//     String? userEmail = _auth.currentUser?.email;
//
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Personal Info Screen'),
//         backgroundColor: Colors.orange,
//       ),
//       body: Container(
//         padding: EdgeInsets.only(left: 16, top: 25, right: 16),
//         child: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).unfocus();
//           },
//           child: ListView(
//             children: [
//               Text(
//                 "Edit Profile",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => PersonalInfoScreen()),
//                   );
//                 },
//                 child: Center(
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: 130,
//                         height: 130,
//                         decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                                 width: 10, color: Colors.white),
//                             boxShadow: [
//                               BoxShadow(
//                                   spreadRadius: 2,
//                                   blurRadius: 10,
//                                   color: Colors.black.withOpacity(0.1),
//                                   offset: Offset(0, 10))
//                             ],
//                             image: DecorationImage(
//                                 fit: BoxFit.cover,
//                                 image: NetworkImage("https://i.pinimg.com/474x/47/ba/71/47ba71f457434319819ac4a7cbd9988e.jpg"))),
//                       ),
//                       Positioned(
//
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           width: 40,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                                 width: 4,
//                                 color: Theme
//                                     .of(context)
//                                     .scaffoldBackgroundColor),
//                             color: Colors.orange,
//                           ),
//                           child: Icon(
//                             Icons.edit,
//                             color: Colors.white,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 35,
//               ),
//
//               buildTextField("First Name", "Enter First Name", false),
//               buildTextField("Last Name", "Enter Last Name", false),
//               buildTextField("E-mail", "$userEmail", false),
//               buildTextField("Password", "********", true),
//               SizedBox(
//                 height: 35,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18.0),
//                         ),
//                       ),
//                       backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.grey),
//                     ),
//                     onPressed: () {},
//                     child: Text('Cancel',
//                         style: TextStyle(
//                             color: Colors.black, fontFamily: "Didot")),
//                   ),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18.0),
//                         ),
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: Text('Save',
//                         style: TextStyle(
//                             color: Colors.black, fontFamily: "Didot")),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildTextField(String labelText, String placeholder, bool isPasswordTextField) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 35.0),
//       child: TextField(
//         obscureText: isPasswordTextField ? showPassword : false,
//         decoration: InputDecoration(
//           suffixIcon: isPasswordTextField
//               ? IconButton(
//             onPressed: () {
//               setState(() {
//                 showPassword = !showPassword;
//               });
//             },
//             icon: Icon(
//               Icons.remove_red_eye,
//               color: Colors.grey,
//             ),
//           )
//               : null,
//           contentPadding: EdgeInsets.only(bottom: 3),
//           labelText: labelText,
//           floatingLabelBehavior: FloatingLabelBehavior.always,
//           hintText: placeholder,
//           hintStyle: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:crave_app_final/screens/delete_Screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';

import '../apiKeys.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

Color lightOrange = Color(0xFFFFCC80);

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String lastName = '';
  String profileImageUrl = "https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg";
  String bio = 'Bio';
  String email = 'email';
  String phoneNumber = '0102';

  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference userRef =
  FirebaseDatabase.instance.reference().child('users');

  @override
  void initState() {
    super.initState();
    getUserInfo();
    fetchRestaurants();
  }

  Future<void> getUserInfo() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference refUser =
    FirebaseDatabase.instance.ref('users/$uid');
    refUser.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        firstName = '${data['firstName']}';
        lastName = '${data['lastName']}';
        //profileImageUrl = '${data['profileImageUrl']}';
        if ('${data['profileImageUrl']}' != null) {
          profileImageUrl = '${data['profileImageUrl']}';
        } else {
          profileImageUrl = "";
        }
      });
    });
  }

  Future<PlacesSearchResponse> fetchRestaurants() async {
    // Request permission to access the device's location
    var permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Retrieve the device's current location
      var position = await Geolocator.getCurrentPosition();
      if (position != null) {
        final places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);
        double latitude = position.latitude;
        double longitude = position.longitude;
        final location = Location(lat: latitude, lng: longitude);
        final result = await places.searchNearbyWithRadius(
          location,
          3000, // radius in meters
          type: 'restaurant',
        );
        if (result.status == "OK") {
          return result;
        } else {
          print('Search failed with status: ${result.status}.');
        }
      }
    } else {
      print('Location permission denied');
    }
    // Return an empty PlacesSearchResponse object if there was an error
    return PlacesSearchResponse(status: "ERROR", results: []);
  }

  Future<void> uploadImageToStorage() async {
    String? imageUrl;

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final DatabaseReference refUser =
      FirebaseDatabase.instance.ref('users/$uid');
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      final bytes = await pickedFile?.readAsBytes();
      final encodedData = base64Encode(bytes!);
      imageUrl = encodedData;
      await refUser.set({
        "firstName": firstName,
        "lastName": lastName,
        "profileImageUrl": imageUrl
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userEmail = auth.currentUser?.email;
    String? userName = auth.currentUser?.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  uploadImageToStorage();
                },
                child: Center(
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
                              offset: Offset(0, 10),
                            ),
                          ],
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: profileImageUrl != null &&
                                profileImageUrl.isNotEmpty
                                ? MemoryImage(base64Decode(profileImageUrl))
                            as ImageProvider<Object>
                                : NetworkImage(
                                'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'),
                          ),
                        ),
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
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Colors.orange,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                '$firstName $lastName',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      // TODO: implement settings button functionality
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => build2(context)),
                      );
                    },
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 12,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ListTile(
                leading: Icon(Icons.email),
                title: Text(userEmail!),
                onTap: () {},
              ),
              SizedBox(height: 20.0),
              Text(
                'Restaurants',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              FutureBuilder<PlacesSearchResponse>(
                future: fetchRestaurants(),
                builder: (BuildContext context, AsyncSnapshot<PlacesSearchResponse> snapshot) {
                  if (snapshot.hasData) {
                    final restaurants = snapshot.data!.results;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                        final result = restaurants[index];
                        return ListTile(
                          title: Text(result.name ?? ''),
                          subtitle: Text(result.vicinity ?? ''),
                          trailing: ElevatedButton(
                            child: Text('Leave a review'),
                            onPressed: () {
                              // TODO: implement leave review button functionality
                            },
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget build2(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () {
              // TODO: Implement change password functionality
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordWidget()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Change Email'),
            onTap: () {
              // TODO: Implement change email functionality
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeEmailWidget()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Change Name'),
            onTap: () {
              // TODO: Implement change name functionality
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeNameWidget()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete Account'),
            onTap: () {
              // TODO: Implement delete account functionality
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => deleteScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChangePasswordWidget extends StatefulWidget {
  @override
  _ChangePasswordWidgetState createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully.')),
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleObscureOldPassword() {
    setState(() {
      _obscureOldPassword = !_obscureOldPassword;
    });
  }

  void _toggleObscureNewPassword() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleObscureConfirmPassword() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 16.0),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOldPassword,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleObscureOldPassword,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your old password.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleObscureNewPassword,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a new password.';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleObscureConfirmPassword,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your new password.';
                  } else if (value != _newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                )
                    : Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeEmailWidget extends StatefulWidget {
  @override
  _ChangeEmailWidgetState createState() => _ChangeEmailWidgetState();
}

class _ChangeEmailWidgetState extends State<ChangeEmailWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updateEmail(_emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email updated successfully.')),
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Email'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'New Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a new email address.';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                )
                    : Text('Change Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeNameWidget extends StatefulWidget {
  @override
  _ChangeNameWidgetState createState() => _ChangeNameWidgetState();
}

class _ChangeNameWidgetState extends State<ChangeNameWidget> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final databaseRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid);
        await databaseRef.update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name updated successfully.')),
        );
        Navigator.pop(context);
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Name'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                )
                    : Text('Change Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
