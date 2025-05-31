import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateFirestore() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Course Data with at least 2 questions per topic
  List<Map<String, dynamic>> courses = [
    {
      "title": "Mathematics",
      "topics": [
        {
          "title": "Algebra",
          "idx": 1,
          "questions": [
            {
              "idx": 1,
              "question": "Solve for x: 2x + 3 = 7",
              "correctAnswer": "2",
              "explanation": "Subtract 3 from both sides, then divide by 2.",
              "imageUrl": "https://example.com/q1.png",
              "instructions": "Solve for x.",
              "correctAnswerImage": null
            },
            {
              "idx": 2,
              "question": "Expand (x + 2)(x - 3).",
              "correctAnswer": "x² - x - 6",
              "explanation": "Use the distributive property (FOIL method).",
              "imageUrl": "https://example.com/q2.png",
              "instructions": "Expand the expression.",
              "correctAnswerImage": null
            }
          ]
        },
        {
          "title": "Geometry",
          "idx": 2,
          "questions": [
            {
              "idx": 1,
              "question": "What is the sum of interior angles of a triangle?",
              "correctAnswer": "180 degrees",
              "explanation": "The sum of the angles in a triangle is always 180°.",
              "imageUrl": null,
              "instructions": "Find the total of the interior angles of a triangle.",
              "correctAnswerImage": null
            },
            {
              "idx": 2,
              "question": "Define a right angle.",
              "correctAnswer": "An angle of 90 degrees",
              "explanation": "A right angle is exactly 90 degrees.",
              "imageUrl": null,
              "instructions": "Give the definition of a right angle.",
              "correctAnswerImage": null
            }
          ]
        }
      ]
    },
    {
      "title": "Science",
      "topics": [
        {
          "title": "Physics - Forces",
          "idx": 1,
          "questions": [
            {
              "idx": 1,
              "question": "What is Newton’s second law of motion?",
              "correctAnswer": "F = ma",
              "explanation": "Force is the product of mass and acceleration.",
              "imageUrl": "https://example.com/q3.png",
              "instructions": "Define Newton’s second law.",
              "correctAnswerImage": null
            },
            {
              "idx": 2,
              "question": "What is the unit of force?",
              "correctAnswer": "Newton (N)",
              "explanation": "The SI unit of force is named after Sir Isaac Newton.",
              "imageUrl": null,
              "instructions": "Provide the SI unit for force.",
              "correctAnswerImage": null
            }
          ]
        }
      ]
    },
    {
      "title": "Biology",
      "topics": [
        {
          "title": "Cell Structure",
          "idx": 1,
          "questions": [
            {
              "idx": 1,
              "question": "What is the function of the mitochondria?",
              "correctAnswer": "Produces energy (ATP)",
              "explanation": "The mitochondria are known as the powerhouse of the cell.",
              "imageUrl": "https://example.com/q4.png",
              "instructions": "Explain the role of mitochondria.",
              "correctAnswerImage": null
            },
            {
              "idx": 2,
              "question": "What is the main function of ribosomes?",
              "correctAnswer": "Protein synthesis",
              "explanation": "Ribosomes are responsible for making proteins.",
              "imageUrl": null,
              "instructions": "State the function of ribosomes.",
              "correctAnswerImage": null
            }
          ]
        }
      ]
    },
    {
      "title": "English",
      "topics": [
        {
          "title": "Grammar - Tenses",
          "idx": 1,
          "questions": [
            {
              "idx": 1,
              "question": "Identify the tense in this sentence: 'She had finished her work before dinner.'",
              "correctAnswer": "Past perfect tense",
              "explanation": "The phrase 'had finished' indicates past perfect tense.",
              "imageUrl": null,
              "instructions": "Determine the tense used in the sentence.",
              "correctAnswerImage": null
            },
            {
              "idx": 2,
              "question": "What is the present continuous tense?",
              "correctAnswer": "An action happening right now",
              "explanation": "Present continuous tense is used for ongoing actions (e.g., 'She is running').",
              "imageUrl": null,
              "instructions": "Define the present continuous tense.",
              "correctAnswerImage": null
            }
          ]
        }
      ]
    }
  ];

  // Insert courses into Firestore
  for (var course in courses) {
    DocumentReference courseRef = await firestore.collection('courses').add({
      "title": course["title"],
    });

    // Insert topics for each course
    for (var topic in course["topics"]) {
      DocumentReference topicRef = await courseRef.collection('topics').add({
        "title": topic["title"],
        "idx": topic["idx"],
      });

      // Insert questions for each topic
      for (var question in topic["questions"]) {
        await topicRef.collection('questions').add({
          "idx": question["idx"], // Ensuring questions are indexed
          "question": question["question"],
          "correctAnswer": question["correctAnswer"],
          "explanation": question["explanation"],
          "imageUrl": question["imageUrl"],
          "instructions": question["instructions"],
          "correctAnswerImage": question["correctAnswerImage"],
        });
      }
    }
  }

  print("Firestore database populated successfully!");
}

void main() async {
  await populateFirestore();
}
