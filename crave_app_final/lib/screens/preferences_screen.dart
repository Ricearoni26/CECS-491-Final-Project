import 'package:crave_app_final/questionModel.dart';
import 'package:crave_app_final/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>{

  //Define the data
  List<Question> questionList = getQuestions();
  int currentQuestionIndex = 0;
  List<String> multiSelect = [];
  //List<List<String>> selectedAnswers = [];
  Map<String, List<String>> selectedAnswers = {};

  //Answer? selectedAnswer;


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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child:Text(
                  questionList[currentQuestionIndex].questionText,
                  style: const TextStyle(
                    fontSize: 25,
                    ),
                  ),
            ),
          ),
        ),
        //Notify user of possible choices
        Text(questionList[currentQuestionIndex].multiSelect ? '(Select Multiple)' : '(Select One)',
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
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

  //
  Widget _answerButton(Answer answer){

    //Change color when selected
    bool isSelected = false;
    if (multiSelect.contains(answer.answerText))
      {
        isSelected = true;
      }

    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
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

            bool multiChoice = questionList[currentQuestionIndex].multiSelectPossible();

            //Single choice
            if (!multiChoice)
              {

                multiSelect.clear();
                multiSelect.add(answer.answerText);

              }
            //Multiple Choice
            else
              {

                //If already selected - pressing again will de-select
                if(multiSelect.contains(answer.answerText))
                {

                  print('double click' + answer.answerText);
                  multiSelect.remove(answer.answerText);

                }
                //Hasn't been selected yet
                else
                {

                  multiSelect.add(answer.answerText);

                }
              }
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
       width: MediaQuery.of(context).size.width * 0.75,
       height: 48,
       child: ElevatedButton(
         child: Text(lastQuestion ? 'Submit' : 'Next'),
         style: ElevatedButton.styleFrom(
           shape: const StadiumBorder(),
           backgroundColor: Colors.purpleAccent,
         ),
         onPressed: (){
           //Last question reached - return to home
           if(lastQuestion) {

              print('entered last question');
              selectedAnswers[questionList[currentQuestionIndex].questionText] = multiSelect;
              //selectedAnswers.add(multiSelect);
              //selectedAnswers.add(selectedAnswer?.getStringValue());
              storePreferences();
              print(selectedAnswers);
              Navigator.pop(context); //HomeScreen();

           }
           else{
             //Go next question
             setState(() {
              // print(multiSelect);
              // print('before Selcted ansers');
              // print(selectedAnswers);

               //Deep copy
               List<String> newList = List.from(multiSelect);
               selectedAnswers[questionList[currentQuestionIndex].questionText] = newList;
               //selectedAnswers.add(newList);
               //print(selectedAnswers);
               multiSelect.clear();
               //print(multiSelect);
               //print('');
               currentQuestionIndex++;
               //selectedAnswers.add(selectedAnswer?.getStringValue());
               //selectedAnswer == null;
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
    await ref.set(selectedAnswers);
    //await ref.set({'preferences': selectedAnswers});

  }

}

