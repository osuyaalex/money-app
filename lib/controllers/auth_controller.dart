 import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
final ImagePicker _picker = ImagePicker();
final FirebaseStorage _storage = FirebaseStorage.instance;
class AuthController{

  pickImage(ImageSource source, String imageKey)async{
    XFile? _xfile = await _picker.pickImage(source: source);
    if (_xfile != null) {
      Uint8List imageBytes = await _xfile.readAsBytes();
      // Save image to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(imageKey, base64.encode(imageBytes));
      return imageBytes;
    }
    // If no image is found, return null
    return null;
  }
  pickImages(ImageSource source)async{
    XFile? _file = await _picker.pickImage(source: source);
    if(_file != null){
      return _file.readAsBytes();
    }else{
      print('no image selected');
    }
  }
  uploadProfilePictureToStorage(Uint8List? image)async{
    Reference ref =  _storage.ref().child('Profile').child(_auth.currentUser!.uid);
    UploadTask uploadTask =ref.putData(image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  signUpUsers(String fullName, String email, String password, String confirmPassword, Uint8List? image)async{
    String res = 'something went wrong';
    try{
      if(fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty && image != null){
       UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
       String profileImageUrl = await uploadProfilePictureToStorage(image);
        await _firebaseFirestore.collection('Users').doc(cred.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'password': password,
          'following':[],
          'profilePicture': profileImageUrl
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

  loginCreatorsOrUsers(String email, String password)async{
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