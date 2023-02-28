 import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
final ImagePicker _picker = ImagePicker();
class AuthController{

  pickImage(ImageSource source, String imageKey)async{
    XFile? _xfile = await _picker.pickImage(source: source);
    // if(_xfile != null){
    //   return await _xfile.readAsBytes();
    // }
    if (_xfile != null) {
      Uint8List imageBytes = await _xfile.readAsBytes();

      // Save image to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(imageKey, base64.encode(imageBytes));

      return imageBytes;
    }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? imageString = prefs.getString(imageKey);
    // if (imageString != null) {
    //   return base64.decode(imageString);
    // }

    // If no image is found, return null
    return null;
  }


  signUpUsers(String fullName, String email, String password, String confirmPassword)async{
    String res = 'something went wrong';
    try{
      if(fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty){
       UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _firebaseFirestore.collection('Users').doc(cred.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'password': password,
          'following':[]
        });
        res = 'success';
      }
    }catch(e){
      res= e.toString();
      print(e.toString());
    }
    return res;
  }

  signUpCreators(String fullName, String email, String password, String confirmPassword)async{
    String res = 'something went wrong';
    try{
      if(fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty){
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _firebaseFirestore.collection('Creators').doc(cred.user!.uid).set({
          'FullName': fullName,
          'email': email,
          'password': password,
          'Following': [],
          'uid':_auth.currentUser!.uid,
          'like':[],
          'links':null,
          'contact':null,
          'location':null,
          'linked':null
        });
        res = 'success';
      }
    }catch(e){
      res= e.toString();
      print(e.toString());
    }
    return res;
  }

  loginCreators(String email, String password)async{
    String res = 'Something went wrong';
    try{
      if(email.isNotEmpty && password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'success';
      }

    }catch(e){
      res = e.toString();
    }
    return res;
  }
}