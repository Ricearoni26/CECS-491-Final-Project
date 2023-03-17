class Question{

  final String questionText;
  final bool multiSelect;
  final List<Answer> answerList;

  Question(this.questionText, this.multiSelect, this.answerList);
}

class Answer{

  final String answerText;
  Answer(this.answerText);

  String getStringValue()
  {

    return answerText;

  }

}

List<Question> getQuestions(){
  List<Question> list = [];

  //Add questions and answers here

  list.add(
    Question('What type of food do you like?',
    //Allow multi-select
    true,
    [
      Answer('American'),
      Answer('Mexican'),
      Answer('Chinese'),
      Answer('Indian'),
      Answer('Italian'),
    ],
    ));


  list.add(
      Question('Do you like spicy food?',
        //Single choice
        false,
        [
          Answer('Nope'),
          Answer('A little bit'),
          Answer('I like spicy food'),
          Answer('I am Spice'),
        ],
      ));


  list.add(
      Question('How much do you wanna spend?',
        //Allow multi-select
        true,
        [
          Answer('Cheap'),
          Answer('Average'),
          Answer('Above-Average'),
          Answer('Expensive'),
        ],
      ));


  list.add(
      Question('How far would you mind traveling?',
        //Allow multi-select
        true,
        [
          Answer('Walkable'),
          Answer('Within 10 miles'),
          Answer('Within 25 miles'),
          Answer('Within 50 miles'),
        ],
      ));


  list.add(
      Question('Do you like popular restaurants?',
        //Allow multi-select
        true,
        [
          Answer('Just-opened restaurants'),
          Answer('Fairly new restaurants'),
          Answer('Established restaurants'),
          Answer('Well-known restaurants'),
        ],
      ));


  list.add(
      Question('Type of services',
        //Allow multi-select
        true,
        [
          Answer('Delivery'),
          Answer('Take-out'),
          Answer('Sit-in'),
        ],
      ));


  list.add(
      Question('Additional services',
        //Allow multi-select
        true,
        [
          Answer('Masks-required'),
          Answer('Wheel-chair accessible'),
          Answer('Parking Lot'),
          Answer('Wifi Provided'),
          Answer('Bars'),
          Answer('Vegetarian-Friendly')
        ],
      ));


  list.add(
      Question('Would you like trying new foods outside your preferences?',
        //Single choice
        false,
        [
          Answer('Stick to my preferences'),
          Answer('Stick to my preferences, but an occasional new suggestion'),
          Answer('I like trying new things outside my comfort'),
          Answer('Open to everything'),
        ],
      ));

  return list;

}