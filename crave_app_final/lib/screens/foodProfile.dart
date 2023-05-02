import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FoodProfile extends StatefulWidget {
  const FoodProfile({Key? key}) : super(key: key);

  @override
  State<FoodProfile> createState() => _FoodProfileState();
}

class _FoodProfileState extends State<FoodProfile> {

  //List to hold attributes
  List<String> attributesList = [];


  //Previous stored Attributes
  Map<dynamic, dynamic> previousAttributesMap = {};
  List<String> previousAttributes = [];

  //Get previous attributes from Firebase
  Future<void> fetchAttributes() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$uid/checkIns');

    DatabaseEvent event = await databaseRef.once();
    setState(() {
      previousAttributesMap = event.snapshot.value as Map<dynamic, dynamic>;
    });

  }



  //Selected Attributes
  List<String> selectedAttributes = [];


  @override
  Widget build(BuildContext context) {
    attributesList.add('Cheap');
    attributesList.add('Average');
    attributesList.add('Above-Average');
    attributesList.add('Expensive');
    attributesList.add('Walkable');
    attributesList.add('Within 10 miles');
    attributesList.add('Within 25 miles');
    attributesList.add('Within 50 miles');
    attributesList.add('Just-opened restaurants');
    attributesList.add('Fairly new restaurants');
    attributesList.add('Established restaurants');
    attributesList.add('Well-known restaurants');
    attributesList.add('Delivery');
    attributesList.add('Take-out');
    attributesList.add('Sit-in');
    attributesList.add('Masks-required');
    attributesList.add('Wheel-chair accessible');
    attributesList.add('Parking Lot');
    attributesList.add('Wifi Provided');
    attributesList.add('Bars');
    attributesList.add('Vegetarian-Friendly');
    attributesList.add('Stick to my preferences');
    attributesList.add('Stick to my preferences, but an occasional new suggestion');
    attributesList.add('I like trying new things outside my comfort');
    attributesList.add('Open to everything');


    fetchAttributes();

    //Get list of attributes
    previousAttributes = previousAttributesMap['preferences'];

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 80.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Food Profile',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: (){

                  storePreferences();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Food Preferences Saved!')));
                  Navigator.pop(context);
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 32.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                children: attributesList
                    .map((category) => GestureDetector(
                  onTap: () => selectedAttributes.add(category),
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: previousAttributes.contains(category)
                          ? Colors.greenAccent
                          : Colors.white,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          //
        ],
      ),
    );
  }

  //Store preferences into firebase
  Future storePreferences() async{
    FirebaseDatabase database = FirebaseDatabase.instance;
    final user = FirebaseAuth.instance.currentUser!;
    String UID = user.uid!;

    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(UID).child('checkIns');


    //Remove attribute if selected again
    selectedAttributes.forEach((element) {
      if(previousAttributes.contains(element)){
        selectedAttributes.remove(element);
      }
    });


    //TODO store attributes
    //Update check-ins
    await ref.update({'preferences': selectedAttributes});

    //await ref.set(checkInRest);
    print('storing');

  }
}
