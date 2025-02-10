import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();  // Firebase.initializeApp() automatically configures Firebase using google-services.json (Android) and GoogleService-Info.plist (iOS)
  runApp(MaterialApp(
  home: MyHome(),
));}

class MyHome extends StatefulWidget {
  MyHome({super.key});
  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  var text;
  String? username;
  late StreamSubscription<DocumentSnapshot> subscription;
  final DocumentReference documentReference=FirebaseFirestore.instance.doc("MyData/dummy");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> _signIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return null; // If the user canceled the sign-in, return null.
      }

      GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;

      // If authentication is successful, create credentials and sign-in to Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gsa.accessToken,
        idToken: gsa.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error during sign-in: $e");
      return null;
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }

  void _add(){
    Map<String,String> data=<String,String>{
      "name":"Harshvardhan",
      "desc":"Flutter Developer"
    };
    documentReference.set(data).whenComplete((){
      print("Data added...");
    }).catchError((e)=>print(e));


  }

  void _delete(){
    documentReference.delete().whenComplete((){
      print("Data delete...");
      setState(() {});
    }).catchError((e)=>print(e));
  }

  void _fetch(){
    documentReference.get().then((datasnapshot){
      if(datasnapshot.exists){
        setState(() {
          text=datasnapshot.data();
        });
      }
    }).catchError((e)=>print(e));
  }

  void _update(){
    Map<String,String> data=<String,String>{
      "name":"Harshvardhan",
      "desc":"Employee of Google"
    };
    documentReference.update(data).whenComplete((){
      print("Document updated...");
    }).catchError((e)=>print(e));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase database and authenization"),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      User? user = await _signIn();
                      if (user != null) {
                        username=user.displayName!;
                        print("User signed in: ${user.displayName}");
                      } else {
                        print("Sign-in failed or canceled");
                      }
                    },
                     child: Text("Sign In")
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor:Colors.red),
                    onPressed: () async {
                      await _signOut();
                      print("User signed out.");
                    },
                    child: Text("Sign Out")
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: _add,
                    child: Text("Add Data")
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellowAccent),
                    onPressed: _update,
                    child: Text("Update Data")
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _fetch,
                    child: Text("Fetch Data")
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                    onPressed: _delete,
                    child: Text("Delete Data")
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                (text==null)?Container():Text(text['desc'],style: TextStyle(color: Colors.red),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

