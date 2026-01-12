import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(FirebaseTestApp());

class FirebaseTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Test',
      debugShowCheckedModeBanner: false,
      home: FirebaseTestScreen(),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String status = "Firebase not initialized yet.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  status = "Initializing Firebase...";
                });
                try {
                  await Firebase.initializeApp();
                  await FirebaseFirestore.instance
                      .collection('test')
                      .doc('doc1')
                      .set({'message': 'Firebase connected!'});
                  setState(() {
                    status = "✅ Firebase connected and test data added!";
                  });
                } catch (e) {
                  setState(() {
                    status = "❌ Firebase connection failed: $e";
                  });
                }
              },
              child: Text("Test Firebase Connection"),
            ),
          ],
        ),
      ),
    );
  }
}
