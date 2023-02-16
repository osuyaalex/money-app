import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:walletapp/Creators%20Screen/creators_home.dart';


import '../controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkedController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  Uint8List? _image;
  Uint8List? _profilePic;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _creatorsStream = FirebaseFirestore.instance.collection('Creators').snapshots();
   bool _loading = false;
   final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final String _imageKey = 'image';
  final String _profilePicKey = 'profilePic';




  uploadProfilePictureToStorage(Uint8List? image)async{
    Reference ref =  FirebaseStorage.instance.ref().child('Profile').child(FirebaseAuth.instance.currentUser!.uid);
    UploadTask uploadTask =ref.putData(image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  uploadHeaderToStorage(Uint8List? image)async{
    Reference ref =  FirebaseStorage.instance.ref().child('Header').child(FirebaseAuth.instance.currentUser!.uid);
    UploadTask uploadTask =ref.putData(image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  editProfile()async{
   if(_globalKey.currentState!.validate()){
     setState(() {
       _loading = true;
     });
     CollectionReference creatorCollection = FirebaseFirestore.instance.collection('Creators');
     String profileImageUrl =await uploadHeaderToStorage(_image);
     String profilePicUrl =await uploadProfilePictureToStorage(_profilePic);
     _firestore.collection('Creators').where('uid', isEqualTo:_auth.currentUser!.uid ).
     where('email', isNull:false ).
     get().
     then((QuerySnapshot snapshot){
       int length = snapshot.docs.length;
       snapshot.docs.forEach((DocumentSnapshot document) {
         final String documentId = length.toString();
         final DocumentSnapshot creatorDoc = document;
         creatorCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
           'email':creatorDoc.get('email'),
           'FullName': _fullNameController.text,
           'ID':'ID $documentId',
           'location': _locationController.text,
           'links': _linkedController.text,
           'contact':_contactController.text,
           'uid':FirebaseAuth.instance.currentUser!.uid,
           'like':[],
           'Headers': profileImageUrl,
           'ProfilePic':profilePicUrl
         }).whenComplete((){
           setState(() {
             _loading = false;
           });
           Navigator.push(context, MaterialPageRoute(builder: (context){
             return const CreatorHomeScreen();
           }));

         });
       });
     });
   }

  }
  pickProfileFromGallery()async{
    Uint8List im = await _authController.pickImage(ImageSource.gallery);
    setState(() {
      _profilePic = im;
    });
  }
  pickProfileFromCamera()async{
    Uint8List im = await _authController.pickImage(ImageSource.camera);
    setState(() {
      _profilePic = im;
    });
  }

  pickHeaderFromGallery()async{
    Uint8List im = await _authController.pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }
  pickHeaderFromCamera()async{
    Uint8List im = await _authController.pickImage(ImageSource.camera);
    setState(() {
      _image = im;
    });
  }
  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _linkedController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _globalKey,
      child: Scaffold(
        backgroundColor: Color(0xfffafafa),
        appBar: AppBar(
          leading: const BackButton(
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit profile',
                  style: GoogleFonts.epilogue(
                    color: Colors.black,
                    fontWeight: FontWeight.w700
                  ),
                ),
                TextButton(
                    onPressed: (){
                      editProfile();
                    },
                    child: _loading ? const Text('please wait'):const Text('Save')
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child:StreamBuilder<QuerySnapshot>(
            stream: _creatorsStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              return Column(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  _fullNameController.text = data['FullName'];
                  _linkedController.text = data['links'];
                  _locationController.text = data['location'];
                  _contactController.text = data['contact'];
                  return  Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      //alignment: Alignment.center,
                                      actions: [
                                        TextButton(
                                            onPressed: (){
                                              pickHeaderFromCamera();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Take Picture')
                                        ),
                                        TextButton(
                                            onPressed: (){
                                              pickHeaderFromGallery();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Choose Existing Photo')
                                        )
                                      ],

                                    );
                                  }
                              );
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: 180,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: _image != null ?BoxDecoration(
                                      image:DecorationImage(image: MemoryImage(_image!), fit: BoxFit.fill)
                                  ):const BoxDecoration(
                                      color: Colors.black
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      //alignment: Alignment.center,
                                      actions: [
                                        TextButton(
                                            onPressed: (){
                                              pickProfileFromCamera();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Take Picture')
                                        ),
                                        TextButton(
                                            onPressed: (){
                                              pickProfileFromGallery();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Choose Existing Photo')
                                        )
                                      ],

                                    );
                                  }
                              );
                            },
                            child: SizedBox(
                              child: Padding(
                                padding:  const EdgeInsets.only(top: 110),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child:_profilePic == null? const CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                    ),
                                    radius: 65,

                                  ):CircleAvatar(
                                    backgroundImage: MemoryImage(_profilePic!),
                                    radius: 65,

                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          validator: (v){
                            if(v!.isEmpty){
                              return 'Full Name Must Not Be Empty';
                            }
                          },
                          //initialValue: data['FullName'] ?? 'a',// basically means data['fullName']== null ?'':data['fullName']
                         controller: _fullNameController,

                          decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.w500
                              )
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          //initialValue: data['location']??'',
                          controller: _locationController,
                          onSaved: (v){
                            if(data['location']!= null){
                              data['location'] = v;
                            }
                          },
                          keyboardType: TextInputType.streetAddress,
                          decoration: InputDecoration(
                              labelText: 'Location',
                              labelStyle: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                              )

                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          //initialValue: data['linked']??'',
                          controller: _linkedController,
                          onSaved: (v){
                            if(data['linked']!= null){
                              data['linked'] = v;
                            }
                          },
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                              labelText: 'Linked',
                              labelStyle: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                              )

                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          //initialValue: data['contact'].toString(),
                          controller: _contactController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Contact',
                              labelStyle: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w500,
                              )

                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 40,
                              width: 150,
                              decoration:  BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: const Border(
                                    top: BorderSide(
                                        color: Colors.black
                                    ),
                                    bottom: BorderSide(
                                        color: Colors.black
                                    ),
                                    left: BorderSide(
                                        color: Colors.black
                                    ),
                                    right: BorderSide(
                                        color: Colors.black
                                    ),
                                  )
                              ),
                              child: Center(
                                child: Text('Go to upload',
                                  style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      )
                    ],
                  );
                }).toList(),
              );
            },
          )


        ) ,
      ),
    );
  }
}
