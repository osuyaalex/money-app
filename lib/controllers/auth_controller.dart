 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
final ImagePicker _picker = ImagePicker();
class AuthController{

  pickImage(ImageSource source)async{
    XFile? _xfile = await _picker.pickImage(source: source);
    if(_xfile != null){
      return await _xfile.readAsBytes();
    }
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
          'fullName': fullName,
          'email': email,
          'password': password,
          'Following': [],
          'uid':_auth.currentUser!.uid
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