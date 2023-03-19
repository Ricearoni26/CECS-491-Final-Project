import 'package:crave_app_final/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LoginLoadingScreen extends StatefulWidget {
  const LoginLoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoginLoadingScreen> createState() => _LoginLoadingScreenState();
}

class _LoginLoadingScreenState extends State<LoginLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndAnimate();
  }

  void _getCurrentLocationAndAnimate() {
    Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true).then((Position position) async {
      await Future.delayed(const Duration(milliseconds: 3080));
      setState(() {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1000),
              transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secAnimation,
                  Widget child) {
                animation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuint
                );

                return ScaleTransition(
                  scale: animation,
                  alignment: Alignment.center,
                  child: child,
                );
              },
              pageBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secAnimation) {
                return HomeScreen(currentPosition: position);
              }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                strokeWidth: 10,
                    color: Colors.white,
                  ),
              Text(
                "rave",
                style: TextStyle(
                  fontFamily: "didot",
                  fontSize: 45,
                  color: Colors.white,
                ),
              ),
            ],
          )
      ),
    );
  }
}
