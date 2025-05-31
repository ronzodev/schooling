
import 'package:ai/firbase.dart';
import 'package:ai/pages/main_screen.dart';
import 'package:ai/videos/video_subject_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   
  
  await Firebase.initializeApp(); 
  
   
  runApp(MyApp());
      
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore Setup',
      theme: ThemeData(primarySwatch: Colors.blue),
      
      home:MainScreen() 
      
       
       
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Setup')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await populateFirestore(); // Call the function to populate Firestore
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Firestore database populated!'))
            );
          },
          child: const Text("Populate Firestore"),
        ),
      ),
    );
  }
}


