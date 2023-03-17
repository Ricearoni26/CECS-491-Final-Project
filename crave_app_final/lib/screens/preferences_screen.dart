import 'package:crave_app_final/questionModel.dart';
import 'package:crave_app_final/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>{




  //Define the data
  List<Question> questionList = getQuestions();
  int currentQuestionIndex = 0;
  Answer? selectedAnswer;
  List<String?> selectedAnswers = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Container(
        child: Column(
          children: [
            const Text('Crave Questionnaire',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            _questionWidget(),
            _answerList(),
            _nextButton(),
          ]),
      ),
    );
  }

  _questionWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Question ${currentQuestionIndex + 1}/${questionList.length.toString()}',
        style: const TextStyle(
          fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            questionList[currentQuestionIndex].questionText,
          style: const TextStyle(
            fontSize: 18,
              )
            ,),
        )
      ],
    );
  }


  _answerList(){
    return Column(
      children: questionList[currentQuestionIndex]
          .answerList
          .map(
              (e) => _answerButton(e),
      )
          .toList(),
    );
  }

  Widget _answerButton(Answer answer){

    //Change color when selected
    bool isSelected = answer == selectedAnswer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 48,
      child: ElevatedButton(
          child: Text(answer.answerText),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: isSelected ? Colors.greenAccent : Colors.white,
          ),
        onPressed: (){
          setState(() {
            selectedAnswer = answer;
          });

        },
      ),

    );
  }



   _nextButton() {

      bool lastQuestion = false;
      if(currentQuestionIndex == questionList.length - 1){
        lastQuestion = true;
      };


     return Container(
       width: double.infinity, //MediaQuery.of(context).size.width * 0.5,
       height: 48,
       child: ElevatedButton(
         child: Text(lastQuestion ? 'Submit' : 'Next'),
         style: ElevatedButton.styleFrom(
           shape: const StadiumBorder(),
           backgroundColor: Colors.purpleAccent,
         ),
         onPressed: (){
           //Last question reeached - return to home
           if(lastQuestion) {

              print('entered last question');
              selectedAnswers.add(selectedAnswer?.getStringValue());
              storePreferences();
              print(selectedAnswers);
              Navigator.pop(context); //HomeScreen();

           }
           else{
             //Go next question
             setState(() {
               selectedAnswers.add(selectedAnswer?.getStringValue());
               selectedAnswer == null;
               currentQuestionIndex++;
             });

           }

         },
       ),
     );
   }


   //Store preferences into firebase
  Future storePreferences() async{
    FirebaseDatabase database = FirebaseDatabase.instance;
    final user = FirebaseAuth.instance.currentUser!;
    String UID = user.uid!;

    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(UID).child('preferences');
    await ref.set({'preferences': selectedAnswers});

  }

}

