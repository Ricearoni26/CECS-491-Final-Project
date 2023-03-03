import 'package:flutter/material.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.orange,
      body: Container(
        child: Column(
          children: [
            const Text('Crave Questionarie',
              style: TextStyle(
                fontSize: 25,
              ),
            )
            _questionWidget(),
          ],
        )
      )

    );
  }

  _questionWidget(){
    return Column();
  }

}

