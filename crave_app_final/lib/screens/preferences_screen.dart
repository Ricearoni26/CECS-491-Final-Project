import 'package:crave_app_final/questionModel.dart';
import 'package:flutter/material.dart';

class PreferencesScreen extends StatelessWidget {
   PreferencesScreen({Key? key}) : super(key: key);


  //Define the data
  List<Question> questionList = getQuestions();
  int currentQuestionIndex = 0;
  Answer? selectedAnswer;


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
            color: Colors.white,
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

}

