class Question{

  final String questionText;
  final List<Answer> answerList;

  Question(this.questionText, this.answerList);
}

class Answer{
  final String answerTest;

  Answer(this.answerTest);
}

List<Question> getQuestions(){
  List<Question> list = [];

  //Add questions and answers here

  list.add(
    Question('What type of food do you like?',
    [
      Answer('American'),
      Answer('Mexican'),
      Answer('Chinese'),
      Answer('Indian'),
    ],
    ));


  list.add(
      Question('What is your spice tolerance?',
        [
          Answer('None'),
          Answer('Small'),
          Answer('Medium'),
          Answer('Large'),
        ],
      ));


  list.add(
      Question('How much do you wanna spend?',
        [
          Answer('Cheap'),
          Answer('Average'),
          Answer('Above-Average'),
          Answer('Expensive'),
        ],
      ));

  return list;

}